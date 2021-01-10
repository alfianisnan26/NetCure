import 'package:NetCure/dialogboxes.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:NetCure/database/db.dart';

class ForgotPassword extends StatefulWidget {
  static const String id = 'register';

  @override
  _FP createState() => _FP();
}

class _FP extends State<ForgotPassword> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    setState(() {
      loading = false;
    });
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loading = false;
  }

  var phoneController = TextEditingController();
  var emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 70,
                ),
                Image(
                  image: AssetImage('assets/images/pills.png'),
                  alignment: Alignment.center,
                  height: 100.0,
                  width: 100.0,
                ),
                SizedBox(
                  height: 40,
                ),
                Text('Forgot password',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontFamily: 'Brand-Bold')),
                Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Column(
                    children: <Widget>[
                      // Fullname
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              fontSize: 16.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10)),
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      // Email Addr

                      // Phone
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                              fontSize: 16.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(
                        height: 40,
                      ),

                      SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width - 75,
                          child: Container(
                              padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                textColor: Colors.black,
                                color: Color.fromRGBO(155, 246, 161, 1),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    (loading)
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator())
                                        : Text('SHOW HINTS'),
                                  ],
                                ),
                                onPressed: loading
                                    ? null
                                    : () async {
                                        setState(() {
                                          loading = true;
                                        });
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());

                                        var connectivityResult =
                                            await Connectivity()
                                                .checkConnectivity();
                                        if (connectivityResult !=
                                                ConnectivityResult.mobile &&
                                            connectivityResult !=
                                                ConnectivityResult.wifi) {
                                          showSnackBar(
                                              'No internet connectivity. Try again');
                                          return;
                                        }

                                        if (!emailController.text
                                            .contains('@')) {
                                          showSnackBar(
                                              'Please provide a valid email address');
                                          return;
                                        }
                                        if (phoneController.text.length < 10) {
                                          showSnackBar(
                                              'Please provide a valid phone numebr');
                                          return;
                                        }

                                        if (!await profile.checkMail(
                                            onEmail: emailController.text)) {
                                          showSnackBar(
                                              "Account not found, please re-register");
                                        } else {
                                          if (await profile.getMyHints(
                                              emailController.text,
                                              phoneController.text)) {
                                            print(profile.data.hints);
                                            Navigator.pop(context);
                                            ackAlert(context, "Hints",
                                                profile.data.hints);
                                          } else {
                                            showSnackBar("Permission Denied");
                                          }
                                          setState(() {
                                            loading = false;
                                          });
                                        }
                                      },
                              ))),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Already have an account? Login here'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
