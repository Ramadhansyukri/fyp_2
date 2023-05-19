import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/screens/user_home_screen.dart';
import 'package:fyp_2/screens/wrapper.dart';
import 'package:fyp_2/shared/theme_helper.dart';
import 'package:fyp_2/widgets/header_widget.dart';

import '../services/auth.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({Key? key}) : super(key: key);

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool isEmailVerified = false;
  bool canResendEmail = true;
  final _formKey = GlobalKey<FormState>();
  Timer? timer;
  final AuthService _auth = AuthService();

  double headerHeight = 300;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if(!isEmailVerified){
      timer = Timer.periodic(
        const Duration(seconds: 3),
          (_) =>checkEmailVerified(),
      );

    }
  }

  @override
  void dispose(){
    timer?.cancel();

    super.dispose();
  }

  Future checkEmailVerified() async{

    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const UserHome()
      : Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: headerHeight,
              child: HeaderWidget(headerHeight, true, Icons.email),
            ),
            SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Please verify your email',
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54
                            ),
                            // textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10,),
                          Text('We will email you a verification code to check your authenticity.',
                            style: TextStyle(
                              color: Colors.black38,
                              // fontSize: 20,
                            ),
                            // textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: ThemeHelper().buttonBoxDecoration(context),
                            child: ElevatedButton(
                              style: ThemeHelper().buttonStyle(),
                              onPressed: canResendEmail ? () async{
                                if(_formKey.currentState!.validate()){
                                  _auth.sendVerificationEmail();
                                  setState(() => canResendEmail = false);
                                  await Future.delayed(const Duration(seconds: 60));
                                  setState(() => canResendEmail = true);
                                }
                              } : null,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    40, 10, 40, 10),
                                child: Text(
                                  "Send".toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(100, 50),
                            ),
                            onPressed: () {
                              _auth.SignOut();
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Wrapper()));
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  40, 10, 40, 10),
                              child: Text(
                                "Cancel".toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      )
  );
}
