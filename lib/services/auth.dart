import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyp_2/models/user_models.dart';

class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Users? _userFromFirebaseUser(User user){
    return user != null ? Users(uid: user.uid) : null;
  }

  Future signIn(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      Fluttertoast.showToast(
          msg: "Signed in successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16.0
      );

      return _userFromFirebaseUser(user!);
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
      return null;
    }
  }

  Future SignOut() async {
    try{
      return await _auth.signOut();
    }catch (e){
      return null;
    }
  }

  Future resetPassword(String email) async {
    try{
      await _auth
          .sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch(e){
      return e;
    }
  }

}