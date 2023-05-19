import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_models.dart';

class UserDatabaseService{

  final String uid;
  UserDatabaseService({ required this.uid});

  final CollectionReference userdata = FirebaseFirestore.instance.collection('users');

  Future setuserdata(String username, String email, String phoneNo, String usertype) async {

    final userData = Users(
      uid: uid,
      email: email,
      name: username,
      phone: phoneNo,
      usertype: usertype
    );

    await userdata.doc(uid).set(userData.toJson());
  }
}