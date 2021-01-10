import 'package:NetCure/database/profile.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:NetCure/login/registrationpage.dart';
import 'package:connectivity/connectivity.dart';
import 'dashboard.dart' as dashboard;
import 'database/setting.dart';
import 'package:NetCure/database/db.dart' as db;
import 'package:NetCure/login/forgotpass.dart';
import 'package:NetCure/emergency/maps.dart' as mp;
import 'package:NetCure/database/hospital.dart' as hp;

void main() {
  runApp(OpenClass());
}

class OpenClass extends StatefulWidget {
  _OpenClass createState() => _OpenClass();
}

MyTheme themeInit = MyTheme();

class _OpenClass extends State<OpenClass> {
  @override
  Widget build(BuildContext context) {
    themeInit.addListener(() {
      setState(() {});
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => NetCure(),
        '/Login': (context) => NetCureLogin(),
        //=>
        // mp.Maps(),
        '/RegistrationPage': (context) => RegistrationPage(),
        '/Dashboard': (context) => dashboard.Dashboard(),
        '/Dashboard/Settings': (context) => SettingScreen(),
        '/Dashboard/Profile': (context) => MyProfile(),
        '/Login/Forgot': (context) => ForgotPassword()
      },
      themeMode: themeInit.currentTheme(),
      theme: themeInit.get(false),
      darkTheme: themeInit.get(true),
    );
  }
}

Future<void> initializeSetting(
    BuildContext context, String email, String pass) async {
  setting = await db.profile.getSetting();
  bool dm = setting.theme.darkMode;
  setting.theme = themeInit;
  setting.theme.switchTheme(dm);
  setting.screenSize = MediaQuery.of(context).size;
  setting.email = email;
  setting.pass = pass;
  setting.saveSetting();
  print('Setting Found this true value ${setting.thisTrue}');
  print('Auto Login Account');
  mp.maps.updatePos().then((value) => Navigator.pushNamedAndRemoveUntil(
      context, "/Dashboard", (route) => false));
}

class NetCure extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<NetCure> {
  void initialize() async {
    hp.hospital.loadHospital();
    print('Load Setting Complete');
    WidgetsFlutterBinding.ensureInitialized();
    Setting newSet = await setting.loadSetting();
    if (newSet != null && newSet.thisTrue) {
      int resp = await db.profile.login(newSet.email, newSet.pass);
      print("Login Auto Resp : " + resp.toString());
      if (resp == 0) {
        await initializeSetting(context, newSet.email, newSet.pass);
        return;
      }
    }
    Navigator.pushNamedAndRemoveUntil(context, "/Login", (route) => false);
    return;
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

String prevEmail;

class NetCureLogin extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<NetCureLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  _dissKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

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

  bool logIn = false;
  @override
  void initState() {
    super.initState();
    logIn = false;
  }

  bool cpassObs = true;
  @override
  Widget build(BuildContext context) {
    if (regist) {
      Future.delayed(const Duration(milliseconds: 500), () {
        showSnackBar("Account created successfully, please login");
      });
      regist = false;
    }
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
                    Container(
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
                          obscureText: cpassObs,
                          controller: passwordController,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                fontSize: 16.0,
                              ),
                              suffixIcon: IconButton(
                                  icon: Icon(!cpassObs
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      cpassObs = !cpassObs;
                                    });
                                  }),
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 10.0)),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
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
                                      Navigator.pushNamed(
                                          context, '/RegistrationPage');
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
                                    child: (logIn)
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator())
                                        : Text('Login'),
                                    onPressed: (logIn)
                                        ? null
                                        : () async {
                                            setState(() {
                                              logIn = true;
                                            });
                                            _dissKeyboard(context);
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
                                              setState(() {
                                                logIn = false;
                                              });
                                              return;
                                            }

                                            if (!emailController.text
                                                .contains('@')) {
                                              showSnackBar(
                                                  'Please enter a valid email address');
                                              setState(() {
                                                logIn = false;
                                              });
                                              return;
                                            }

                                            if (passwordController.text.length <
                                                8) {
                                              showSnackBar(
                                                  'Password must be atleast 8 characters');
                                              setState(() {
                                                logIn = false;
                                              });
                                              return;
                                            }
                                            if (prevEmail !=
                                                emailController.text) {
                                              prevEmail = emailController.text;
                                              db.profile.counter = 0;
                                            }

                                            // check if user exists
                                            switch (await db.profile.login(
                                                emailController.text,
                                                passwordController.text)) {
                                              case 1:
                                                showSnackBar(
                                                    "Account not found");
                                                break;
                                              case 2:
                                                showSnackBar(
                                                    "Password does not match");
                                                break;
                                              case 3:
                                                showSnackBar(
                                                    "Password does not match, forget password?");
                                                break;
                                              case 4:
                                                showSnackBar(
                                                    "Account is expired, please re-register");
                                                break;
                                              case 5:
                                                showSnackBar("Unknown Error");
                                                break;
                                              case 0:
                                                {
                                                  await initializeSetting(
                                                      context,
                                                      emailController.text,
                                                      passwordController.text);
                                                  break;
                                                }
                                              default:
                                                {
                                                  showSnackBar(
                                                      "Error, cannot login");
                                                }
                                            }
                                            setState(() {
                                              logIn = false;
                                            });
                                          },
                                  )),
                            ],
                          ))
                    ])),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed("/Login/Forgot");
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
