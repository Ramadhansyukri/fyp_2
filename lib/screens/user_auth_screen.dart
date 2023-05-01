import 'package:flutter/material.dart';
import 'package:fyp_2/screens/user_register.dart';
import 'package:fyp_2/screens/user_sign_in.dart';

class UserAuth extends StatefulWidget {
  const UserAuth({Key? key}) : super(key: key);

  @override
  State<UserAuth> createState() => _UserAuthState();
}

class _UserAuthState extends State<UserAuth> {

  bool showSignIn = true;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return UserSignIn(toggleView: toggleView);
    }else {
      return UserReg(toggleView: toggleView);
    }
  }
}
