import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/services/auth.dart';
import 'package:fyp_2/widgets/header_widget.dart';
import 'package:fyp_2/shared/theme_helper.dart';

import 'forgot_password_screen.dart';

class UserSignIn extends StatefulWidget {
  //const UserSignIn({Key? key}) : super(key: key);
  final Function () onClickedRegister;

  const UserSignIn({Key?key, required this.onClickedRegister,}) : super(key: key);

  @override
  State<UserSignIn> createState() => _UserSignInState();
}

class _UserSignInState extends State<UserSignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final double _headerHeight = 250;

  var email = '';
  var password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: _headerHeight,
              child: HeaderWidget(_headerHeight, true, Icons.login_rounded), //let's create a common header widget
            ),
            SafeArea(
              child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),// This will be the login form
                  child: Column(
                    children: [
                      const Text(
                        'Hello!',
                        style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Sign in into your account',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 30.0),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                decoration: ThemeHelper().inputBoxDecorationShadow(),
                                child: TextFormField(
                                    decoration: ThemeHelper().textInputDecoration('Email', 'Enter your email'),
                                    validator: (val){
                                      if(val!.isEmpty){
                                        return "Email can't be empty";
                                      }
                                      else if(!EmailValidator.validate(val)){
                                        return "Enter a valid email address";
                                      }
                                      return null;
                                    },
                                    onChanged: (val) {
                                      setState(() => email = val);
                                    }
                                ),
                              ),
                              const SizedBox(height: 30.0),
                              Container(
                                decoration: ThemeHelper().inputBoxDecorationShadow(),
                                child: TextFormField(
                                    obscureText: true,
                                    decoration: ThemeHelper().textInputDecoration('Password', 'Enter your password'),
                                    validator: (val) => val!.length <8 ? 'Password must be at least 8 character' : null,
                                    onChanged: (val){
                                      setState(() => password = val);
                                    }
                                ),
                              ),
                              const SizedBox(height: 15.0),
                              Container(
                                margin: const EdgeInsets.fromLTRB(10,0,10,20),
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push( context, MaterialPageRoute( builder: (context) => const ForgotPassword()), );
                                  },
                                  child: const Text( "Forgot your password?", style: TextStyle( color: Colors.grey, ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: ThemeHelper().buttonBoxDecoration(context),
                                child: ElevatedButton(
                                  style: ThemeHelper().buttonStyle(),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                                    child: Text('Sign In'.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                                  ),
                                  onPressed: () async{
                                    if (_formKey.currentState!.validate()){
                                      await _auth.signIn(email, password);
                                    }
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(10,20,10,20),
                                child: Text.rich(
                                    TextSpan(
                                        children: [
                                          const TextSpan(text: "Don't have an account? "),
                                          TextSpan(
                                            text: 'Create',
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = widget.onClickedRegister,
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                                          ),
                                        ]
                                    )
                                ),
                              ),
                              const SizedBox(height: 12.0,),
                              Text(
                                error,
                                style: const TextStyle(color: Colors.red, fontSize: 14.0),
                              )
                            ],
                          )
                      ),
                    ],
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

