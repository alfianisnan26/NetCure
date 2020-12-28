import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:NetCure/login/registrationpage.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dashboard.dart' as dashboard;
import 'package:NetCure/login/progressdialog.dart';
import 'setting.dart';

void main() {
  runApp(OpenClass());
}

class OpenClass extends StatefulWidget {
  _OpenClass createState() => _OpenClass();
}

class _OpenClass extends State<OpenClass> {
  initialize() async {
    //await Config.initSetting();
    print('Load Setting Complete');
    setting.theme.addListener(() {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => NetCure(),
        '/Login': (context) => NetCureLogin(),
        '/RegistrationPage': (context) => RegistrationPage(),
        '/Dashboard': (context) => dashboard.Dashboard(),
        '/Dashboard/Settings': (context) => SettingScreen(),
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
    if (setting.thisTrue)
      Navigator.pushNamed(context, '/Dashboard');
    else
      Navigator.pushNamed(context, '/Login');
  }

  startTime() async {
    var duration = new Duration(seconds: 3);
    return new Timer(duration, route);
  }

  void initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    Setting open = await setting.loadSetting();
    if (open != null) {
      setting = open;
      print('Setting Found this true value ${setting.theme.darkMode}');
      if (setting.thisTrue) {
        print('Auto Login Account');
        setting.theme.switchTheme(setting.theme.darkMode);
      }
    }
  }

  @override
  void initState() {
    startTime();
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setting.screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
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
    );
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
      builder: (BuildContext context) => ProgressDialog(
        'logging in',
      ),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/Dashboard'),
        ),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0, right: 40),
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                fontSize: 16.0,
                              ),
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 10.0)),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0, right: 40),
                        child: TextField(
                          obscureText: true,
                          controller: passwordController,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                fontSize: 16.0,
                              ),
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 10.0)),
                          style: TextStyle(fontSize: 16),
                        ),
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
                                    textColor: Colors.black,
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
                                    textColor: Colors.black,
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
                        style: TextStyle(
                            fontSize: 12,
                            color: (setting.theme.darkMode)
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    )
                  ],
                ))));
  }
}
