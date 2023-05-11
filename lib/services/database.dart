import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{

  final String uid;
  DatabaseService({ required this.uid});

  final CollectionReference userdata = FirebaseFirestore.instance.collection('users');

  Future setuserdata(String username, String email, String phoneNo, String usertype) async {
    return await userdata.doc(uid).set({
      'username': username,
      'email': email,
      'phone number': phoneNo,
      'user type': usertype,
    });
  }
}