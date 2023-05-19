import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../screens/verify_email_screen.dart';
import 'database.dart';

class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future registerWithEmailAndPassword(String email, String password, String username, String phoneNo, String usertype, BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator())
    );

    try{
      dynamic value = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      UserDatabaseService(uid: value.user!.uid).setuserdata(username, email, phoneNo, usertype);
      Fluttertoast.showToast(
      msg: "Successfully signed up",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      fontSize: 20.0,
      backgroundColor: Colors.transparent,
      textColor: Colors.green
      );
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const VerifyEmail()));
    }catch(e){
      Fluttertoast.showToast(
      msg: e.toString(),
      backgroundColor: Colors.transparent,
      textColor: Colors.red
      );
    }

  }

  Future signIn(String email, String password) async {
    try{
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      Fluttertoast.showToast(
          msg: "Signed in successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 20.0,
          backgroundColor: Colors.transparent,
          textColor: Colors.green
      );
    }catch(e){
      Fluttertoast.showToast(
          msg: e.toString(),
          backgroundColor: Colors.transparent,
          textColor: Colors.red
      );
    }
  }

  Future SignOut() async {
    try{
      await _auth.signOut();
      Fluttertoast.showToast(
          msg: "Signed out successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 20.0,
          backgroundColor: Colors.transparent,
          textColor: Colors.green
      );
    }catch (e){
      Fluttertoast.showToast(
          msg: e.toString(),
          backgroundColor: Colors.transparent,
          textColor: Colors.red
      );
    }
  }

  Future resetPassword(String email) async {
    try{
      await _auth.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(
          msg: "Email sent successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 20.0,
          backgroundColor: Colors.transparent,
          textColor: Colors.green
      );
    } on FirebaseAuthException catch(e){
      Fluttertoast.showToast(
          msg: e.toString(),
          backgroundColor: Colors.transparent,
          textColor: Colors.red
      );
    }
  }

  Future sendVerificationEmail() async {
    try{
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      Fluttertoast.showToast(
          msg: "Email sent successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 20.0,
          backgroundColor: Colors.transparent,
          textColor: Colors.green
      );
    } catch(e){
      Fluttertoast.showToast(
          msg: e.toString(),
          backgroundColor: Colors.transparent,
          textColor: Colors.red
      );
    }

  }

}