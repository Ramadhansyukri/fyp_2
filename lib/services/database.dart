import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/models/cart_models.dart';

import '../models/menu_models.dart';
import '../models/restaurant_model.dart';
import '../models/user_models.dart';

class UserDatabaseService{

  final String uid;
  UserDatabaseService({ required this.uid});

  final userdata = FirebaseFirestore.instance.collection('users');

  Future setUser(String username, String email, String phoneNo, String usertype) async {

    String address = "";
    double balance = 0.0;

    final userData = Users(
      uid: uid,
      email: email,
      name: username,
      phone: phoneNo,
      usertype: usertype,
      address: address,
      balance: balance
    );

    if(usertype == 'Customer'){
      await FirebaseFirestore.instance.collection('customer').doc(uid).set(userData.toJson());
    }else if(usertype == 'Restaurant'){
      await FirebaseFirestore.instance.collection('restaurant').doc(uid).set(userData.toJson());
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

      try{
        await userdata.doc(uid).delete();
        if(usertype == "Restaurant"){
          await FirebaseFirestore.instance.collection('restaurant').doc(uid).delete();
        }else if(usertype == "Rider"){
          await FirebaseFirestore.instance.collection('rider').doc(uid).delete();
        }else {
          await FirebaseFirestore.instance.collection('customer').doc(uid).delete();
        }
      }catch(e){
        print(e);
    }
  }

  Future<void> updateAddress(String address, String usertype) async {
    await userdata.doc(uid).update({'address': address});
    if(usertype == "Restaurant"){
      await FirebaseFirestore.instance.collection('restaurant').doc(uid).update({'address': address});
    }else if(usertype == "Rider"){
      await FirebaseFirestore.instance.collection('rider').doc(uid).update({'address': address});
    }else {
      await FirebaseFirestore.instance.collection('customer').doc(uid).update({'address': address});
    }
  }

  Future<String> getUserAddress() async {
    final userDoc = await userdata.doc(uid).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final addressLine = userData['address'];
      return '$addressLine';
    }
    return ''; // Return an empty string or handle the case when the restaurant is not found
  }

  Future addUserBalance(double amount) async {
    final userRef = userdata.doc(uid);
    await userRef.update({'balance': FieldValue.increment(amount)});
  }

  Future deductUserBalance(double amount) async {
    final userRef = userdata.doc(uid);
    await userRef.update({'balance': amount});
  }

  Future<double> getUserBalance() async {
    final userDoc = await userdata.doc(uid).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final balance = userData['balance'];
      return balance;
    }
    return 0.0; // Return an empty string or handle the case when the restaurant is not found
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

  Future deleteMenu() async {

    try{
      await menuDb.doc(uid).delete();
    }catch(e){
      print(e);
    }

  }
}

class RestDatabaseService{
  final String? uid;
  RestDatabaseService({ required this.uid});

  final restData = FirebaseFirestore.instance.collection('restaurant');

  Future setRest(String imageUrl, String address) async {

    final restdata = Restaurant(
        uid: uid,
        imageUrl: imageUrl,
        address: address,
    );

    await restData.doc(uid).set(
        restdata.toJson(),
        SetOptions(merge: true)
    );
  }

  Future<Restaurant?> getRest() async {
    final restDoc = restData.doc(uid);
    final snapshot = await restDoc.get();

    if(snapshot.exists) {
      return Restaurant.fromJson(snapshot.data()!);
    }
    return null;
  }

  Future<String> getRestaurantAddress(String restaurantId) async {
    final restaurantDoc = await restData.doc(restaurantId).get();
    if (restaurantDoc.exists) {
      final restaurantData = restaurantDoc.data() as Map<String, dynamic>;
      final addressLine1 = restaurantData['address'];
      return '$addressLine1';
    }
    return ''; // Return an empty string or handle the case when the restaurant is not found
  }
}

class CartService{
  final String? uid;
  CartService({required this.uid});

  final userdata = FirebaseFirestore.instance.collection('customer');

  Future addToCart(String menuID, String menuName, double price, String imageUrl, String? restID, BuildContext context) async{
    final existingCart = await userdata.doc(uid).collection('cart').get();

    // Check if any cart item already exists in the cart
    if (existingCart.docs.isNotEmpty) {
      final firstCartItem = existingCart.docs.first.data();
      final firstMenuID = firstCartItem['id'] as String;

      // Extract the restaurantID from the first menuID
      final existingRestaurantID = firstMenuID.substring(0, 5);

      // Extract the restaurantID from the new menuID
      final newRestaurantID = menuID.substring(0, 5);

      // Compare the restaurantIDs
      if (existingRestaurantID != newRestaurantID) {
        // Show alert dialog and handle the user's choice
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Different Restaurant'),
            content: const Text(
              'You already have items from a different restaurant in your cart. '
                  'Adding items from a different restaurant will clear your current cart. '
                  'Do you want to continue?',
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Continue'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );

        // Handle the user's choice
        if (result != null && result) {
          // Clear the existing cart
          await clearCart();
        } else {
          // User chose to cancel, so return without adding the new item
          return;
        }
      }
    }

    final cartData = CartItem(
      id: menuID,
      name: menuName,
      price: price,
      imageUrl: imageUrl,
      restID: restID as String,
      quantity: 1,
    );

    await userdata.doc(uid).collection('cart').doc(menuID).set(cartData.toJson());
  }

  Future<List<CartItem>> getCartItems() async {
    final cartItemsSnapshot = await userdata
        .doc(uid)
        .collection('cart')
        .get();

    return cartItemsSnapshot.docs
        .map((doc) => CartItem.fromJson(doc.data()))
        .toList();
  }

  Future<void> updateCartItem(CartItem cartItem) {
    if (cartItem.quantity == 0) {
      return removeCartItem(cartItem);
    } else {
      return userdata
          .doc(uid)
          .collection('cart')
          .doc(cartItem.id)
          .set(cartItem.toJson());
    }
  }

  Future<void> removeCartItem(CartItem cartItem) {
    return userdata
        .doc(uid)
        .collection('cart')
        .doc(cartItem.id)
        .delete();
  }

  Future<void> clearCart() {
    return userdata.doc(uid).collection('cart').get().then((snapshot) {
      final batch = FirebaseFirestore.instance.batch();
      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      return batch.commit();
    });
  }
}

class OrderDatabaseService {
  final CollectionReference orderCollection = FirebaseFirestore.instance.collection('Order');

  Future<void> createOrder(String userid, String restId, double deliveryFee, double total, String address) async {
    List<CartItem> cartItems = await CartService(uid: userid).getCartItems();

    try {
      String orderId = DateTime.now().toIso8601String().substring(0, 16).replaceAll('-', '').replaceAll(':', '');

      Map<String, dynamic> orderData = {
        'userId': userid,
        'restaurantId': restId,
        'deliveryFee': deliveryFee,
        'totalAmount': total,
        'address': address,
        'dateTime': DateTime.now(),
      };

      await orderCollection.doc(orderId).set(orderData);

      List<Map<String, dynamic>> itemsData = cartItems.map((cartItem) => cartItem.toJson()).toList();

      CollectionReference itemsCollection = orderCollection.doc(orderId).collection('items');

      for (int i = 0; i < itemsData.length; i++) {
        await itemsCollection.doc('item$i').set(itemsData[i]);
      }

      await CartService(uid: userid).clearCart();
    } catch (e) {
      print('Error creating order in Firestore: $e');
      // Handle the error
    }
  }
}





