import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_2/models/user_models.dart';
import 'package:fyp_2/services/database.dart';

class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Users? _userFromFirebaseUser(User user){
    return user != null ? Users(uid: user.uid) : null;
  }

  Stream<Users?> get user {
    return _auth.authStateChanges()
        .map((User? user) => _userFromFirebaseUser(user!));
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

  Future registerWithEmailAndPassword(String email, String password, String username, String phoneNo, String usertype) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      await DatabaseService(uid: result.user!.uid).setuserdata(username, email, phoneNo, usertype);

      return null;
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
      await _auth
          .sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch(e){
      return e;
    }
  }

  Future sendVerificationEmail() async{
    try{
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } on FirebaseAuthException catch(e){
      return e;
    }
  }
}