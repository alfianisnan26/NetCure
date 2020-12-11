import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
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

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void registerUser() async {
    final UserCredential userCredential = (await _auth
        .createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
        .catchError((ex) {
  
      // check error and display messages
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);
    }));

    final uid = FirebaseAuth.instance.currentUser.uid;
    final DatabaseReference newUserRef =
        FirebaseDatabase.instance.reference().child('users/${uid}');

    //prepare data to be saved on user table
    Map userMap = {
      'fullname': fullNameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
    };

    newUserRef.set(userMap);

    // Take user to the mainPage
    Navigator.pushNamedAndRemoveUntil(context, '/Dashboard', (route) => false);
  }

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
                Text('Create a new account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontFamily: 'Brand-Bold')),
                Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Column(
                    children: <Widget>[
                      // Fullname
                      TextField(
                        controller: fullNameController,
                        decoration: InputDecoration(
                            labelText: 'Full Name',
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

                      // Email Address
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'Email address',
                            labelStyle: TextStyle(
                              fontSize: 16.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(
                        height: 10,
                      ),

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
                        height: 10,
                      ),

                      // Password
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            fontSize: 16.0,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          ),
                        ),
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
                                    Text('REGISTER'),
                                  ],
                                ),
                                onPressed: () async {
                                  //check network availability
                                  var connectivityResult =
                                      await Connectivity().checkConnectivity();
                                  if (connectivityResult !=
                                          ConnectivityResult.mobile &&
                                      connectivityResult !=
                                          ConnectivityResult.wifi) {
                                    showSnackBar(
                                        'No internet connectivity. Try again');
                                    return;
                                  }

                                  if (fullNameController.text.length < 4) {
                                    showSnackBar(
                                        'Please enter a valid full name');
                                    return;
                                  }
                                  if (phoneController.text.length < 10) {
                                    showSnackBar(
                                        'Please provide a valid phone numebr');
                                    return;
                                  }
                                  if (!emailController.text.contains('@')) {
                                    showSnackBar(
                                        'Please provide a valid email address');
                                    return;
                                  }
                                  if (passwordController.text.length < 8) {
                                    showSnackBar(
                                        'Password length at least 8 characters');
                                    return;
                                  }
                                  registerUser();
                                },
                              ))),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/Login', (route) => false);
                  },
                  child: Text('Already have rider account? Login here'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
