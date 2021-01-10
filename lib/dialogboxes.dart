import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'newsapi.dart' show Articles;
import 'dashboard.dart';
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

void addRoutines(CardClass cardRoutines, var context) {
  TextEditingController rouControl = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Add Routines"),
        content: Row(
          children: [
            TextField(
              controller: rouControl,
              decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    fontSize: 16.0,
                  ),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 10)),
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              cardRoutines.myCards.add(CardItem(
                () => ackAlert(
                    context, "Routines", "${rouControl.value.toString()}"),
                Colors.greenAccent,
                Center(child: Text("${rouControl.value.toString()}")),
                Center(
                  child: Text("${rouControl.value.toString()}"),
                ),
                Center(child: Text("${rouControl.value.toString()}")),
              ));
              cardRoutines.renderCards("Add_Routines");
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
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
