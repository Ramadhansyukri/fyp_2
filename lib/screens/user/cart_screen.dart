import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/screens/user/set_address.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import '../../models/cart_models.dart';
import '../../models/user_models.dart';
import '../../services/database.dart';
import 'package:bcrypt/bcrypt.dart' as encrypt;
import 'package:get/get.dart';

import '../home_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key, required this.user}) : super(key: key);

  final Users? user;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  double _deliveryFee = 0.0;
  String _userAddress = '';
  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    await _fetchCartItems();
    await _fetchUserAddress();
    _calculateDeliveryFee();
  }

  Future<void> _fetchCartItems() async {
    List<CartItem> cartItems = await CartService(uid: widget.user!.uid).getCartItems();
    setState(() {
      _cartItems = cartItems;
    });
  }

  Future<void> _fetchUserAddress() async {
    final userAddress = await UserDatabaseService(uid: widget.user!.uid.toString()).getUserAddress();
    setState(() {
      _userAddress = userAddress;
    });
  }

  void _calculateDeliveryFee() async {
    try {
      if (_cartItems.isEmpty) {
        _deliveryFee = 0;
        return;
      }

      final String restID = _cartItems[0].restID;
      String restaurantAddress = await RestDatabaseService(uid: restID).getRestaurantAddress(restID);

      List<Location> userLocations = await locationFromAddress(_userAddress);
      Location userLocation = userLocations.first;

      List<Location> restaurantLocations = await locationFromAddress(restaurantAddress);
      Location restaurantLocation = restaurantLocations.first;

      double distanceInMeters = await Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        restaurantLocation.latitude,
        restaurantLocation.longitude,
      );

      const double feePerKilometer = 2.0;
      double deliveryFee = (distanceInMeters / 1000) * feePerKilometer;

      // Round up the delivery fee to 2 decimal places
      setState(() {
        _deliveryFee = double.parse((deliveryFee).ceilToDouble().toStringAsFixed(2));
      });
    } catch (e) {
      print('Error calculating delivery fee: $e');
    }
  }

  void updateAddress(String newAddress) {
    setState(() {
      _userAddress = newAddress;
    });
    _calculateDeliveryFee();
  }

  void _increaseQuantity(CartItem cartItem) {
    setState(() {
      cartItem.quantity++;
    });
    _updateCartItem(cartItem);
  }

  void _decreaseQuantity(CartItem cartItem) {
    setState(() {
      if (cartItem.quantity > 0) {
        cartItem.quantity--;
        if (cartItem.quantity == 0) {
          _removeCartItem(cartItem);
        } else {
          _updateCartItem(cartItem);
        }
      }
    });
  }

  void _updateCartItem(CartItem cartItem) async {
    await CartService(uid: widget.user!.uid).updateCartItem(cartItem);
  }

  void _removeCartItem(CartItem cartItem) async {
    setState(() {
      _cartItems.remove(cartItem);
    });
    await CartService(uid: widget.user!.uid).removeCartItem(cartItem);
  }

  void _clearCart() async {
    setState(() {
      _cartItems.clear();
    });
    await CartService(uid: widget.user!.uid).clearCart();
  }

  double _calculateTotal() {
    double total = 0;
    for (var cartItem in _cartItems) {
      total += (cartItem.price * cartItem.quantity);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: (){
              _clearCart();
              _calculateDeliveryFee();
              MotionToast.delete(
                  title:  const Text("Deleted"),
                  description:  const Text("The item is deleted")
              ).show(context);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: _cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = _cartItems[index];
                  return CartItemWidget(
                    cartItem: cartItem,
                    increaseQuantity: _increaseQuantity,
                    decreaseQuantity: _decreaseQuantity,
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  )
                ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Address:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _userAddress.isEmpty ? "No saved Address" : _userAddress,
                            style: const TextStyle(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push( context, MaterialPageRoute(builder: (context) => SetAddressScreen(user: widget.user,updateAddress: updateAddress,)),);
                            },
                            child: const Text(
                              'Change delivery address',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: [
                              Text(
                                'Subtotal: RM${_calculateTotal().toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Delivery Fee: RM${_deliveryFee.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total Fee: RM${(_calculateTotal() + _deliveryFee).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          )
                        )
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          _PinScreen(
                            context,
                            opaque: false,
                            cancelButton: const Text(
                              'Cancel',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                              semanticsLabel: 'Cancel',
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green,
                        ),
                        child: const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _PinScreen(
      BuildContext context, {
        required bool opaque,
        CircleUIConfig? circleUIConfig,
        KeyboardUIConfig? keyboardUIConfig,
        required Widget cancelButton,
        List<String>? digits,
      }) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
                title: const Text(
                  'Enter App Passcode',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
                circleUIConfig: circleUIConfig,
                keyboardUIConfig: keyboardUIConfig,
                passwordEnteredCallback: _onPasscodeEntered,
                cancelButton: cancelButton,
                deleteButton: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  semanticsLabel: 'Delete',
                ),
                shouldTriggerVerification: _verificationNotifier.stream,
                backgroundColor: Colors.black.withOpacity(0.8),
                cancelCallback: _onPasscodeCancelled,
                digits: digits,
                passwordDigits: 6,
              ),
        ));
  }

  void _onPasscodeCancelled() {
    Navigator.maybePop(context);
  }

  void _onPasscodeEntered(String enteredPasscode) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.user!.uid);
    final userData = await userDoc.get();
    final storedPin = userData.get('PIN') as String;
    final bool isPinValid = encrypt.BCrypt.checkpw(enteredPasscode, storedPin);
    _verificationNotifier.add(isPinValid);
    if (isPinValid) {
      _checkout();
    }
  }

  void _checkout() async {
    double totalAmount = _calculateTotal() + _deliveryFee;
    double userBalance = await UserDatabaseService(uid: widget.user!.uid.toString()).getUserBalance();

    if (totalAmount > userBalance) {
      if (context.mounted){
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          title: 'Oops...',
          text: 'Insufficient Balance',
          loopAnimation: false,
        );
      }
      return;
    }

    await UserDatabaseService(uid: widget.user!.uid.toString()).deductUserBalance(totalAmount);

    await OrderDatabaseService().createOrder(widget.user!.uid.toString(), _cartItems[0].restID, _deliveryFee, totalAmount, _userAddress);

    if (context.mounted){
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: 'Transaction completed successfully!',
      ).then((_) {
        Get.offAll(() => const Home(), transition: Transition.rightToLeft);
      });
    }
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final Function(CartItem) increaseQuantity;
  final Function(CartItem) decreaseQuantity;

  const CartItemWidget({
    Key? key,
    required this.cartItem,
    required this.increaseQuantity,
    required this.decreaseQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(cartItem.imageUrl),
      ),
      title: Text(cartItem.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price: RM${cartItem.price.toStringAsFixed(2)}'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => decreaseQuantity(cartItem),
                icon: const Icon(Icons.remove),
              ),
              Text(cartItem.quantity.toString()),
              IconButton(
                onPressed: () => increaseQuantity(cartItem),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
