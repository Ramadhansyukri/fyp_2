import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/models/cart_models.dart';
import 'package:fyp_2/models/order_model.dart';

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
    }else if(usertype == 'Rider'){
      await FirebaseFirestore.instance.collection('rider').doc(uid).set(userData.toJson());
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

  Future<bool> addToCart(String menuID, String menuName, double price, String imageUrl, String? restID, String? instruction, BuildContext context) async{
    final existingCart = await userdata.doc(uid).collection('cart').get();
    bool cancelResult = true;

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

        await CoolAlert.show(
            context: context,
            type: CoolAlertType.confirm,
            title: "Item from different restaurant",
            text: 'You cannot add item from a different restaurant, do you want to clear your cart and add this item?',
            confirmBtnText: 'Yes',
            cancelBtnText: 'No',
            confirmBtnColor: Colors.green,
            onConfirmBtnTap: () async {
              cancelResult = true;
            },
            onCancelBtnTap: () {
              cancelResult = false;
            }
        );

        // Handle the user's choice
        if (cancelResult == true) {
          // Clear the existing cart
          await clearCart();
        } else {
          // User chose to cancel, so return without adding the new item
          return cancelResult;
        }
      }
    }

    final cartData = CartItem(
      id: menuID,
      name: menuName,
      price: price,
      imageUrl: imageUrl,
      restID: restID as String,
      instruction: instruction,
      quantity: 1,
    );

    await userdata.doc(uid).collection('cart').doc(menuID).set(cartData.toJson());
    return cancelResult;
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
      String userIdPrefix = userid.substring(0, 3);
      String restIdPrefix = restId.substring(0, 3);

      String orderId = '${userIdPrefix}_${restIdPrefix}_${DateTime.now().toIso8601String().substring(0, 16).replaceAll('-', '').replaceAll(':', '')}';
      DateTime dateTime = DateTime.now();

      final orderData = OrderModel(
        orderID: orderId,
          userID: userid,
          restID: restId,
          deliveryFee: deliveryFee,
          total: total,
          address: address,
          dateTime: dateTime,
        status: 'Received'
      );

      await orderCollection.doc(orderId).set(orderData.toJson());

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

  Future<void> assignOrderToRider(OrderModel order, String riderId) async {
    try {
      // Update the order document in the "Order" collection with the rider ID
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final orderDoc = await transaction.get(orderCollection.doc(order.orderID));
        if (orderDoc.exists) {
          transaction.update(orderCollection.doc(order.orderID), {'riderID': riderId});
        }
      });

      /*// Retrieve the updated order document
      final updatedOrderDoc = await orderCollection.doc(order.orderID).get();

      if (updatedOrderDoc.exists) {
        final orderData = updatedOrderDoc.data() as Map<String, dynamic>;
        final itemsSnapshot = await updatedOrderDoc.reference.collection('items').get();

        // Create a new document in the "OrderTaken" collection using the order document data
        await FirebaseFirestore.instance.collection('OrderTaken').doc(order.orderID).set(orderData);

        // Transfer each item document to the new "OrderTaken" collection
        for (final itemDoc in itemsSnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('OrderTaken')
              .doc(order.orderID)
              .collection('items')
              .doc(itemDoc.id)
              .set(itemDoc.data());

          // Delete the item document from the original "Order" collection
          await itemDoc.reference.delete();
        }

        // Delete the order document from the original "Order" collection
        await orderCollection.doc(order.orderID).delete();

        // Display a success message or perform any other necessary actions
        print('Order assigned to rider successfully.');
      } else {
        print('Order document does not exist.');
      }*/
    } catch (e) {
      print('Error assigning order to rider in Firestore: $e');
      // Handle the error
    }
  }

  Stream<List<OrderModel>> orderStream() {
    return orderCollection
        .where('riderID', isEqualTo: null)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return OrderModel.fromJson(data);
    }).toList());
  }
}

class RiderDatabaseService {
  final String uid;
  RiderDatabaseService({required this.uid});

  final riderData = FirebaseFirestore.instance.collection('rider');

  Future<bool> checkCurrentOrder() async {
    final currentOrderSnapshot = await riderData.doc(uid).collection('currentorder').limit(1).get();
    return currentOrderSnapshot.docs.isNotEmpty;
  }

  Future<OrderModel?> getCurrentOrder() async {
    final currentOrderSnapshot = await riderData
        .doc(uid)
        .collection('currentorder')
        .limit(1)
        .get();

    if (currentOrderSnapshot.docs.isNotEmpty) {
      final data = currentOrderSnapshot.docs[0].data();
      return OrderModel.fromJson(data);
    }

    return null;
  }

  Future<void> takeOrder(OrderModel order) async {
    final currentOrderRef = riderData.doc(uid).collection('currentorder').doc(order.orderID);
    await currentOrderRef.set(order.toJson());
  }

}