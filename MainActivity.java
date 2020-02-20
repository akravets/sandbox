package com.iwaysoftware.webfocus_flutter_app;

import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.os.Bundle;
import android.content.Context;
import java.io.InputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.io.IOException;
import java.io.File;
import android.net.Uri;
import android.util.Log;
import android.content.ContentUris;
import android.provider.*;
import android.database.Cursor;
import android.content.ContentResolver;

import android.content.Intent;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodCall;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "com.iwaysoftware.webFocusMobile/report";
  private static final String TAG = "MY_ACTIVITY";
  private Context context = this;

  private UriIdentifier uriIdentifier;

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    new MethodChannel(getFlutterEngine().getDartExecutor(), CHANNEL).setMethodCallHandler(new MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("getReportFile")) {
          String res = getReportFile();
          result.success(res);
        }
      }
    });
  }



  private String getReportFile() {
    Uri data = getIntent().getData();

    if (data == null) {
      return "no_report_to_load";
    }
    
    if (uriIdentifier == null) {
      uriIdentifier = new UriIdentifier(data);
    }
    else if (uriIdentifier.getHashCode() == data.hashCode()) {
      return "reports_is_same";
    }
    else {
      uriIdentifier = new UriIdentifier(data);
    }

    if (data != null) {
      try {
        InputStream is = getContentResolver().openInputStream(data);

        ByteArrayOutputStream result = new ByteArrayOutputStream();
        byte[] buffer = new byte[1024];
        int length;
        while ((length = is.read(buffer)) != -1) {
          result.write(buffer, 0, length);
        }

        String f = getContentName(getContentResolver(), data);
        return f + "###" + result.toString(StandardCharsets.UTF_8.name());
      } catch (IOException e) {
        return e.getLocalizedMessage();
      }
      finally {
        data = null;
      }
    }
    return "No report to display";
  }

  public static String getContentName(ContentResolver resolver, Uri uri) {
    Cursor cursor = resolver.query(uri, new String[] { MediaStore.MediaColumns.DISPLAY_NAME }, null, null, null);
    cursor.moveToFirst();
    int nameIndex = cursor.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME);
    if (nameIndex >= 0) {
      return cursor.getString(nameIndex);
    }

    return null;
  }
  
  private class UriIdentifier {
    Uri uri;
    int hashCode;

    public UriIdentifier(Uri uri) {
      this.uri = uri;
      this.hashCode = uri.hashCode();
    }

    /**
     * @return the uri
     */
    public Uri getUri() {
      return uri;
    }

    /**
     * @return the hashCode
     */
    public int getHashCode() {
      return hashCode;
    }
    
  }
}
