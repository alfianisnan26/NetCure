import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:NetCure/database/db.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

bool regist = false;

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
    setState(() {
      loading = false;
    });
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  bool loading = false;

  @override
  void initState() {
    super.initState();
    regist = false;
    loading = false;
  }

  bool passObs = true;
  bool cpassObs = true;

  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  var cpassController = TextEditingController();
  var hintsController = TextEditingController();

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
                        obscureText: passObs,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            fontSize: 16.0,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          ),
                          suffixIcon: IconButton(
                              icon: Icon(!passObs
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  passObs = !passObs;
                                });
                              }),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      // Password
                      TextField(
                        controller: cpassController,
                        obscureText: cpassObs,
                        decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(
                              fontSize: 16.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            ),
                            suffixIcon: IconButton(
                                icon: Icon(!cpassObs
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    cpassObs = !cpassObs;
                                  });
                                })),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      // Password
                      TextField(
                        controller: hintsController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Hints',
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
                                    (loading)
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator())
                                        : Text('REGISTER'),
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

                                        if (fullNameController.text.length <
                                            4) {
                                          showSnackBar(
                                              'Please enter a valid full name');
                                          return;
                                        }
                                        if (phoneController.text.length < 10) {
                                          showSnackBar(
                                              'Please provide a valid phone numebr');
                                          return;
                                        }
                                        if (!emailController.text
                                            .contains('@')) {
                                          showSnackBar(
                                              'Please provide a valid email address');
                                          return;
                                        }
                                        if (passwordController.text.length <
                                            8) {
                                          showSnackBar(
                                              'Password length at least 8 characters');
                                          return;
                                        }
                                        if (passwordController.text !=
                                            cpassController.text) {
                                          showSnackBar(
                                              "Password does not match");
                                          return;
                                        }
                                        if (hintsController.text.length < 4) {
                                          showSnackBar(
                                              "Please enter hints in case for forgetting password");
                                          return;
                                        }

                                        if (await profile.checkMail(
                                            onEmail: emailController.text)) {
                                          showSnackBar(
                                              "Email is registered, please use another email");
                                        } else {
                                          if (await profile.generate(
                                              fullNameController.text,
                                              phoneController.text,
                                              emailController.text,
                                              passwordController.text,
                                              hintsController.text)) {
                                            regist = true;
                                            setState(() {
                                              loading = false;
                                            });
                                            Navigator.pop(context);
                                            return;
                                          } else {
                                            regist = false;
                                            return;
                                          }
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
