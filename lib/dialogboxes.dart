import 'package:NetCure/database/db.dart';
import 'package:NetCure/database/setting.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
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

Future<bool> dialogToDelete(var context, String msg) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Are you sure want to delete?"),
        content: Text(msg),
        actions: [
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop(true);
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

ValueNotifier<int> tempNewsCount = ValueNotifier(5);
ValueNotifier<double> ratioMax = ValueNotifier(0.8);
ValueNotifier<double> ratioMin = ValueNotifier(0.3);

class SDSlider extends StatefulWidget {
  _SDS createState() => _SDS();
}

class _SDS extends State<SDSlider> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text("CureBar Ratio"),
      children: [
        RangeSlider(
          labels: RangeLabels("${ratioMin.value.toStringAsPrecision(2)}",
              "${ratioMax.value.toStringAsPrecision(2)}"),
          values: RangeValues(ratioMin.value, ratioMax.value),
          onChanged: (val) {
            setState(() {
              ratioMin.value = val.start;
              ratioMax.value = val.end;
            });
          },
        ),
        Center(
            child: Text(ratioMin.value.toStringAsPrecision(2) +
                "-" +
                ratioMax.value.toStringAsPrecision(2)))
      ],
    );
  }
}

class ASlider extends StatefulWidget {
  _ASDS createState() => _ASDS();
}

class _ASDS extends State<ASlider> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text("CureBar Ratio"),
      children: [
        Slider(
          divisions: 15,
          max: 15,
          label: "${tempNewsCount.value}",
          value: tempNewsCount.value.toDouble(),
          onChanged: (val) {
            setState(() {
              tempNewsCount.value = val.round();
            });
          },
        ),
        Center(child: Text(tempNewsCount.value.toString()))
      ],
    );
  }
}

class AddRoutines extends StatefulWidget {
  _AR createState() => _AR();
}

class _AR extends State<AddRoutines> {
  Size s;
  Widget separator({String label = ""}) {
    return Container(
      color: Colors.grey.withOpacity(0.5),
      height: 20,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      width: s.width,
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }

  Widget tiles(List<Widget> myChild, {Color color}) {
    return Container(
      height: 60,
      color: color,
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      width: s.width,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: myChild),
    );
  }

  Widget scheduler() {
    if (myAlarms.length > 0) {
      return Column(
        children: List<Widget>.generate(myAlarms.length, (index) {
          return tiles([
            Text(myAlarms[index].name),
            MaterialButton(
                child: Text(myAlarms[index].alarms.toString()),
                onLongPress: () {
                  dialogToDelete(context, myAlarms[index].name).then((value) {
                    if (value) {
                      myAlarms.removeAt(index);
                    }
                  });
                },
                onPressed: () async {
                  final TimeOfDay ouPut = await showRoundedTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (ouPut != null) {
                    setState(() {
                      myAlarms[index].alarms = ouPut;
                      print("Modified");
                    });
                  }
                })
          ]);
        }),
      );
    } else
      return tiles(
        [Text("No Alarms", style: TextStyle(color: Colors.grey))],
      );
  }

  List<Alarms> myAlarms = [];

  TextEditingController _tcTitle = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _tcTitle.text = "New Routines";
    s = setting.screenSize;
    return Dialog(
        child: Container(
            width: s.width,
            child: Column(
              children: [
                Stack(alignment: AlignmentDirectional.center, children: [
                  Container(
                      width: s.width,
                      height: s.height * 0.2,
                      child: Image.asset(
                        "assets/images/pillsBW.jpg",
                        fit: BoxFit.cover,
                        color: (setting.theme.darkMode)
                            ? Colors.black38
                            : Colors.white38,
                        colorBlendMode: (setting.theme.darkMode)
                            ? BlendMode.darken
                            : BlendMode.lighten,
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center,
                        controller: _tcTitle,
                      ))
                ]),
                separator(label: "SCHEDULER"),
                tiles([
                  Text("Add Alarm", style: TextStyle(fontSize: 18)),
                  IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        final TimeOfDay ouPut = await showRoundedTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        if (ouPut != null) {
                          setState(() {
                            myAlarms.add(Alarms(
                                alarms: ouPut,
                                name: "My Alarms Number : " +
                                    myAlarms.length.toString()));
                          });
                          print("Added");
                        }
                      })
                ], color: Colors.grey),
                scheduler()
              ],
            )));
    ;
  }
}

Future<bool> routineAdd(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AddRoutines();
      });
}
