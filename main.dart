import 'dart:async';
import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:f_logs/f_logs.dart';

//App listens to com.iwaysoftware.webFocusMobile/report channel and invokes getReportFile method to read data from platform,
//after the invokation data is saved in app's local storage and upon successful write reload webView with newly created file.

void main() {
  runApp(SampleApp());
}

class SampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Webfocus Reports',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebViewContainer(),
    );
  }
}

class WebViewContainer extends StatefulWidget {
  @override
  createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> with WidgetsBindingObserver {
  static const platform = const MethodChannel('com.iwaysoftware.webFocusMobile/report');

  // stores fileName to be displayed in WebView
  String _fileName = "";
  FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    writeLog("Initializing state...");

    _getFile();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    writeLog("ApplifecycleState changed to state: $state");
    if (state == AppLifecycleState.resumed) {
      _getFile();
    }
  }

  //Gets file from channel, saves it to local storage and reloads webView
  _getFile() async {
    writeLog("Entering method...");
    var data = await platform.invokeMethod("getReportFile"); // CALLS BUILD HERE?
    writeLog("Got data by invoking getReportFile...");

    // controller returns data in the form of {fileName}###{payload}
    int indexOfSeparator = data.indexOf("###");

    if (indexOfSeparator < 0) {
      writeLog("No ### delimeter detected, wrong file. Returning...");
      return;
    }

    String fileName = data.substring(0, indexOfSeparator);
    String content = data.substring(indexOfSeparator + 3);

    if (_fileName != fileName) {
      setState(() {
        _fileName = fileName;
        writeLog("Setting fileName in state: $fileName");
      });
    }

    final file = await _localFile(fileName);

    writeData(file, content).then((f) {
      writeLog("File write OK, reloading webView with file ${file.path}");
      flutterWebviewPlugin.reloadUrl('file://${file.path}');
    });
  }

  // Get local path where to save the file
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    writeLog("Got localPath: $directory.path");
    return directory.path;
  }

  // Create file to write data to
  Future<File> _localFile(String filename) async {
    final path = await _localPath;

    File file = File('$path/$filename.html');

    if (file.existsSync()) {
      file.deleteSync();
    }

    return file;
  }

  // Writes data to file
  Future<File> writeData(File file, String content) async {
    writeLog("Writing $file to device");
    return file.writeAsString(content);
  }

  @override
  Widget build(BuildContext context) {
    writeLog("In build() method");
    FLog.exportLogs();

    if (_fileName == "") {
      return Scaffold(
        body: Text("No report to display"),
        appBar: AppBar(title: Text("Report")),
      );
    }

    return WebviewScaffold(
      url: 'about.blank',
      withJavascript: true,
      appBar: AppBar(
        title: Text("$_fileName"),
      ),
    );
  }

  writeLog(String text) {
    FLog.info(className: "WebFOCUS", text: text);
  }
}
