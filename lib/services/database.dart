import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/menu_models.dart';
import '../models/user_models.dart';

class UserDatabaseService{

  final String uid;
  UserDatabaseService({ required this.uid});

  final userdata = FirebaseFirestore.instance.collection('users');

  Future setUser(String username, String email, String phoneNo, String usertype) async {

    final userData = Users(
      uid: uid,
      email: email,
      name: username,
      phone: phoneNo,
      usertype: usertype
    );

    if(usertype == "Restaurant"){
      await FirebaseFirestore.instance.collection('restaurant').doc(uid).set(userData.toJson());
    }else if(usertype == "Rider"){
      await FirebaseFirestore.instance.collection('rider').doc(uid).set(userData.toJson());
    }else {
      await FirebaseFirestore.instance.collection('customer').doc(uid).set(userData.toJson());
    }

    await userdata.doc(uid).set(userData.toJson());
  }

  Future<Users?> getUser() async {
    final userDoc = userdata.doc(uid);
    final snapshot = await userDoc.get();

    if(snapshot.exists) {
      return Users.fromJson(snapshot.data()!);
    }
    return null;
  }

  Future deleteAccount(String usertype) async {

      await userdata.doc(uid).delete();
      if(usertype == "Restaurant"){
        await FirebaseFirestore.instance.collection('restaurant').doc(uid).delete();
      }else if(usertype == "Rider"){
        await FirebaseFirestore.instance.collection('rider').doc(uid).delete();
      }else {
        await FirebaseFirestore.instance.collection('customer').doc(uid).delete();
      }

  }
}

class MenuDatabaseService{
  final String? uid;
  MenuDatabaseService({ required this.uid});

  final menuDb = FirebaseFirestore.instance.collection('restaurant');

  Future setMenu(String restaurantName, String imageUrl, String name, String desc, double price) async {

    final querySnapshot = await menuDb.doc(uid).collection('menu').get();
    int count = querySnapshot.docs.length;
    count += 1;
    final String menuId = '${restaurantName.replaceAll(' ', '_')}_${count.toString().padLeft(5, '0')}';

    final menuData = Menu(
        menuID: menuId,
        imageUrl: imageUrl,
        name: name,
        desc: desc,
        price: price
    );

    await menuDb.doc(uid).collection('menu').doc(menuId).set(menuData.toJson());
  }

  Future<Menu?> getMenu() async {
    final menuDoc = menuDb.doc(uid).collection('menu').doc();
    final snapshot = await menuDoc.get();

    if(snapshot.exists) {
      return Menu.fromJson(snapshot.data()!);
    }
    return null;
  }
}