import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dashboard.dart' as dashboard;
import 'registrationpage.dart' as registrationpage;
import 'package:re_netcure/progressdialog.dart';
import 'setting.dart';

void main() {
  runApp(OpenClass());
}

class OpenClass extends StatefulWidget {
  _OpenClass createState() => _OpenClass();
}

class _OpenClass extends State<OpenClass> {
  @override
  void initState() {
    super.initState();
    setting.init();
    setting.theme.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => NetCure(),
        '/Login': (context) => NetCureLogin(),
        '/Dashboard': (context) => dashboard.Dashboard(),
        '/Dashboard/Settings': (context) => SettingScreen()
      },
      themeMode: setting.theme.currentTheme(),
      theme: setting.theme.get(false),
      darkTheme: setting.theme.get(true),
    );
  }
}

class NetCure extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<NetCure> {
  route() {
    Navigator.pushNamed(context, '/Login');
  }

  startTime() async {
    var duration = new Duration(seconds: 3);
    return new Timer(duration, route);
  }

  runFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  void initState() {
    super.initState();
    startTime();
    runFirebase();
  }

  @override
  Widget build(BuildContext context) {
    setting.screenSize = MediaQuery.of(context).size;
    return Scaffold(
        body: Hero(
      tag: 'banner',
      child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(10),
          child: Stack(
            children: [
              Container(
                  padding: EdgeInsets.fromLTRB(150, 0, 0, 0),
                  child: Image.asset(
                    "assets/images/pills.png",
                  )),
              Container(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Image.asset(
                    "assets/images/banner.png",
                    height: 70,
                  ))
            ],
          )),
    ));
  }
}

class NetCureLogin extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<NetCureLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  login() async {

    //show waiting dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog('logging in',),
    );

    final UserCredential userCredential = (await _auth
        .signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
        .catchError((ex) {
      ;
      // check error and display messages
      Navigator.pop(context);
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);
    }));

    final uid = FirebaseAuth.instance.currentUser.uid;
    print(uid);

    if (uid != null) {
      //verify login
      DatabaseReference userRef =
          FirebaseDatabase.instance.reference().child('users/${uid}');

      userRef.once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/Dashboard', (route) => false);
        }
      });
    }
    return uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    Hero(
                      tag: 'banner',
                      child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          child: Stack(
                            children: [
                              Container(
                                  padding: EdgeInsets.fromLTRB(150, 0, 0, 0),
                                  child: Image.asset(
                                    "assets/images/pills.png",
                                  )),
                              Container(
                                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                                  child: Image.asset(
                                    "assets/images/banner.png",
                                    height: 70,
                                  ))
                            ],
                          )),
                    ),
                    SizedBox(height: 20),
                    Container(
                        child: Column(children: [
                      Row(children: [
                        SizedBox(
                          width: 40,
                        ),
                        Text("Email",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 10)),
                      ]),
                      Container(
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: emailController,
                          decoration: InputDecoration(
                            isDense: true,
                          ),
                        ),
                      ),
                      Row(children: [
                        SizedBox(
                          width: 40,
                        ),
                        Text("Password",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 10)),
                      ]),
                      Container(
                        height: 40,
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          obscureText: true,
                          textAlign: TextAlign.center,
                          controller: passwordController,
                          decoration: InputDecoration(
                            isDense: true,
                          ),
                        ),
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
                                color: Colors.white,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Image.asset(
                                      'assets/images/google.png',
                                      height: 20,
                                    ),
                                    Text('Sign in with Google')
                                  ],
                                ),
                                onPressed: () {
                                  print(emailController.text);
                                  print(passwordController.text);
                                },
                              ))),
                      SizedBox(
                          height: 60,
                          width: MediaQuery.of(context).size.width - 75,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 75) /
                                          2,
                                  padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    textColor: Colors.white,
                                    color: Color.fromRGBO(99, 219, 167, 1),
                                    child: Text('Sign Up'),
                                    onPressed: () {
                                      //go to Sign Up Page
                                      Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          '/RegistrationPage',
                                          (route) => false);
                                    },
                                  )),
                              Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 75) /
                                          2,
                                  padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    textColor: Colors.white,
                                    color: Color.fromRGBO(155, 246, 161, 1),
                                    child: Text('Login'),
                                    onPressed: () async {
                                      // check if user exists
                                      login();
                                      if (login()) {
                                        showSnackBar(
                                            'Login failed, check detail or Register');
                                        return;
                                      }

                                      //check network availability
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

                                      if (!emailController.text.contains('@')) {
                                        showSnackBar(
                                            'Please enter a valid email address');
                                        return;
                                      }

                                      if (passwordController.text.length < 8) {
                                        showSnackBar(
                                            'Password must be atleast 8 characters');
                                        return;
                                      }
                                    },
                                  )),
                            ],
                          ))
                    ])),
                    FlatButton(
                      onPressed: () {
                        //forgot password screen
                      },
                      textColor: Colors.black,
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    )
                  ],
                ))));
  }
}
