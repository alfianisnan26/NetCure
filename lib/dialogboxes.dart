import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'newsapi.dart' show Articles;
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

// ignore: must_be_immutable
class WebViewScreen extends StatefulWidget {
  Articles resp;
  WebViewScreen({Key key, @required this.resp}) : super(key: key);
  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (await canLaunch(widget.resp.url)) {
              await launch(widget.resp.url);
            } else {
              ackAlert(context, "Error", "Could not open url");
            }
          },
          child: Icon(Icons.open_in_browser)),
      appBar: AppBar(
          title: Text(
        widget.resp.title,
        overflow: TextOverflow.fade,
      )),
      body: WebView(
        initialUrl: widget.resp.url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

void ackAlert(var context, String title, String msg) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
