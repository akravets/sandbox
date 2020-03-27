import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import './pages/SitesPage.dart';
import './pages/FexListPage.dart';
import './pages/WebviewPage.dart';
import './pages/ReportViewer.dart';
import './models/AppDataModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var database = openDatabase(
    join(await getDatabasesPath(), 'wf_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE sites(title TEXT PRIMARY KEY, host TEXT, port INTEGER, context TEXT, userName TEXT, password TEXT, secure INTEGER, newInterface INTEGER)",
      );
    },
    version: 1,
  );

  runApp(WebFocusHomePage(database));
}

class WebFocusHomePage extends StatefulWidget {
  final database;

  WebFocusHomePage(this.database);

  @override
  _WebFocusHomePageState createState() => _WebFocusHomePageState();
}

class _WebFocusHomePageState extends State<WebFocusHomePage> with WidgetsBindingObserver{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppDataModel>(
        create: (context) => AppDataModel(widget.database),
        child:  MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'WebFOCUS',
            theme: ThemeData(
                primarySwatch: Colors.blue,
                accentColor: Colors.amberAccent,
                textTheme: ThemeData.light().textTheme.copyWith(
                    title: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    button: TextStyle(color: Colors.white)),
                appBarTheme: AppBarTheme(
                    color: Colors.blue,
                    textTheme: ThemeData.light().textTheme.copyWith(
                        title: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    actionsIconTheme: IconThemeData(color: Colors.white))),
            routes: {
                '/': (context) => SitesPage(),
                '/faves': (context) => FexListPage(),
                '/webview': (context) => WebviewPage(),
                '/reports': (context) => ReportViewer(),
              }));
  }
}
