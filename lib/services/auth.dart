import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_2/models/user_models.dart';

class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Users? _userFromFirebaseUser(User user){
    return user != null ? Users(uid: user.uid) : null;
  }

  Stream<Users?> get user {
    return _auth.authStateChanges()
        .map((User? user) => _userFromFirebaseUser(user!));
  }

  Future SignInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user!);
    }catch(e){
      return null;
    }
  }

  Future registerWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user!);
    }catch(e){
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
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e){
      print(e);
    }

  }
}