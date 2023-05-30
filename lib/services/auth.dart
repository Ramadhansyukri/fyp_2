import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../screens/verify_email_screen.dart';
import 'database.dart';

class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future registerWithEmailAndPassword(
      String email, String password, String username, String phoneNo, String usertype, BuildContext context,
      String imageUrl, String address
      ) async {

    try{
      dynamic value = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      UserDatabaseService(uid: value.user!.uid).setUser(username, email, phoneNo, usertype);

      if(usertype == "Restaurant"){
        await RestDatabaseService(uid: value.user!.uid).setRest(imageUrl, address);
      }

      Fluttertoast.showToast(
      msg: "Successfully signed up",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      fontSize: 20.0,
      backgroundColor: Colors.green.withOpacity(0.8),
      textColor: Colors.white
      );
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const VerifyEmail()));
    }catch(e){
      Fluttertoast.showToast(
      msg: e.toString(),
          fontSize: 20.0,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          textColor: Colors.white
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
          backgroundColor: Colors.green.withOpacity(0.8),
          textColor: Colors.white
      );
    }catch(e){
      Fluttertoast.showToast(
          msg: e.toString(),
          fontSize: 20.0,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          textColor: Colors.white
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
          backgroundColor: Colors.green.withOpacity(0.8),
          textColor: Colors.white
      );
    }catch (e){
      Fluttertoast.showToast(
          msg: e.toString(),
          fontSize: 20.0,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          textColor: Colors.white
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
          backgroundColor: Colors.green.withOpacity(0.8),
          textColor: Colors.white
      );
    } on FirebaseAuthException catch(e){
      Fluttertoast.showToast(
          msg: e.toString(),
          fontSize: 20.0,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          textColor: Colors.white
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
          backgroundColor: Colors.green.withOpacity(0.8),
          textColor: Colors.white
      );
    } catch(e){
      Fluttertoast.showToast(
          msg: e.toString(),
          fontSize: 20.0,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          textColor: Colors.white
      );
    }

  }

  Future deleteAccount(String usertype) async {
    try {

      String ? userId = _auth.currentUser?.uid;
      String uid = userId.toString();
      try{
        await UserDatabaseService(uid: uid).deleteAccount(usertype);
      }catch(e){
        print(e);
      }


      await _auth.currentUser?.delete();

      Fluttertoast.showToast(
          msg: "Account deleted",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 20.0,
          backgroundColor: Colors.green.withOpacity(0.8),
          textColor: Colors.white
      );

    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          fontSize: 20.0,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          textColor: Colors.white
      );
    }
  }

}