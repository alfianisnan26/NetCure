import 'package:NetCure/database/db.dart';
import 'package:NetCure/database/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';

class MyProfile extends StatefulWidget {
  @override
  _MP createState() => _MP();
}

class _MP extends State<MyProfile> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Widget menuProfile(String title, Widget child) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1)),
        height: 70,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), child]));
  }

  Widget menuSeparator(String text) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1)),
        width: setting.screenSize.width,
        height: 15,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(text,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    color: Theme.of(context).primaryColor))));
  }

  Widget menuDecease(String title, {Widget child}) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1)),
        height: 70,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: (child == null)
                ? [
                    Text(
                      title,
                      style: TextStyle(color: Colors.grey),
                    )
                  ]
                : [
                    Text(
                      title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    child
                  ]));
  }

  @override
  void initState() {
    super.initState();
    if (profile.data.personal.deceases == null)
      profile.data.personal.deceases = [];
  }

  TextEditingController _tfc = TextEditingController();

  Future<bool> dialog() async {
    bool foreturn = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Decease"),
          content: TextField(
            controller: _tfc,
          ),
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                foreturn = false;
                _tfc.text = "";
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                if (_tfc.text.isNotEmpty) {
                  foreturn = true;
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
    return foreturn;
  }

  deseaseWidget() {
    return Column(children: [
      menuProfile(
          "My Deseases",
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                dialog().then((value) {
                  if (value) {
                    print(_tfc.text);
                    setState(
                        () => profile.data.personal.deceases.add(_tfc.text));
                    _tfc.text = "";
                  }
                });
              })),
      (profile.data.personal.deceases == null ||
              profile.data.personal.deceases.length == 0)
          ? menuDecease("No Decease")
          : Column(
              children: List<Widget>.generate(
                  profile.data.personal.deceases.length, (index) {
                return menuDecease(profile.data.personal.deceases[index],
                    child: IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        profile.data.personal.deceases.removeAt(index);
                        setState(() {});
                      },
                    ));
              }),
            )
    ]);
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text("My Profile"),
        ),
        body: Builder(
          builder: (context) {
            return SingleChildScrollView(
              child: Stack(children: [
                Column(
                  children: [
                    Container(
                        width: setting.screenSize.width,
                        height: setting.screenSize.height * 0.3,
                        color: Colors.grey,
                        child: (profile.data.personal.myPhoto == null)
                            ? Image.asset("assets/images/pillsBW.jpg",
                                fit: BoxFit.cover)
                            : Image.memory(
                                profile.data.personal.myPhoto,
                                fit: BoxFit.cover,
                              )),
                    menuSeparator("PROFILE"),
                    menuProfile("Name", Text(profile.data.name)),
                    menuProfile(
                        "DOB",
                        MaterialButton(
                            color: Colors.grey.withOpacity(0.5),
                            child: (profile.data.personal.dob == null)
                                ? Text("Uninitialize")
                                : Text(
                                    "${profile.data.personal.dob.year}/${profile.data.personal.dob.month}/${profile.data.personal.dob.day}"),
                            onPressed: () {
                              showRoundedDatePicker(
                                description: "Date of birth",
                                theme: (setting.theme.darkMode)
                                    ? ThemeData.dark()
                                    : ThemeData.light(),
                                context: context,
                                initialDate: (profile.data.personal.dob != null)
                                    ? profile.data.personal.dob
                                    : DateTime.now(),
                                firstDate: DateTime(DateTime.now().year - 100),
                                lastDate: DateTime.now(),
                                borderRadius: 16,
                              ).then((value) {
                                if (value != null) {
                                  setState(() {
                                    profile.data.personal.dob = value;
                                  });
                                }
                              });
                            })),
                    menuProfile(
                        "Sex",
                        DropdownButton(
                            value: (profile.data.personal.sex != null)
                                ? profile.data.personal.sex
                                : 0,
                            items: [
                              DropdownMenuItem(
                                value: 1,
                                child: Text("Male"),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text("Female"),
                              ),
                              DropdownMenuItem(
                                value: 0,
                                child: Text("Undefine"),
                              )
                            ],
                            onChanged: (value) {
                              setState(() {
                                profile.data.personal.sex = value;
                              });
                            })),
                    menuSeparator("ACCOUNT"),
                    menuProfile("Email", Text(profile.data.email)),
                    menuProfile(
                        "Password",
                        MaterialButton(
                            color: Colors.grey.withOpacity(0.5),
                            child: Text("Change Password"),
                            onPressed: () {})),
                    menuProfile(
                        "Phone Number",
                        MaterialButton(
                            color: Colors.grey.withOpacity(0.5),
                            child: Text(profile.data.phone),
                            onPressed: () {})),
                    menuProfile(
                        "Hints",
                        MaterialButton(
                            color: Colors.grey.withOpacity(0.5),
                            child: Text("Change Hints"),
                            onPressed: () {})),
                    menuSeparator("HEALTHCARE"),
                    deseaseWidget()
                  ],
                ),
                Padding(
                    padding: EdgeInsets.only(
                        top: setting.screenSize.height * 0.3 - 25,
                        left: setting.screenSize.width * 0.80),
                    child: FloatingActionButton(
                      backgroundColor: (loading) ? Colors.grey : null,
                      heroTag: null,
                      onPressed: (loading)
                          ? null
                          : () async {
                              if (await profile.data.personal.updatePhoto()) {
                                print("Photo Updated");
                                setState(() {
                                  loading = true;
                                });
                                if (await profile.updatePersonal()) {
                                  print("Photo Saved to Online");
                                  showSnackBar(
                                      "Photo saved to online database");
                                } else {
                                  print("Cannot Save to online");
                                  showSnackBar("Error saving photo");
                                }
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                      tooltip: 'Pick Image',
                      child: (loading)
                          ? Padding(
                              padding: EdgeInsets.all(3),
                              child: CircularProgressIndicator())
                          : Icon(Icons.add_a_photo),
                    )),
              ]),
            );
          },
        ));
  }
}
