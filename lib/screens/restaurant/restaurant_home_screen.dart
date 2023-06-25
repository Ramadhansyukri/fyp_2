import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fyp_2/screens/restaurant/rest_view_order.dart';
import 'package:fyp_2/screens/restaurant/restaurant_order_history.dart';
import 'package:fyp_2/screens/restaurant/restaurant_setting.dart';
import 'package:fyp_2/screens/restaurant/view_menu.dart';
import 'package:fyp_2/screens/wrapper.dart';
import 'package:get/get.dart';

import '../../models/order_model.dart';
import '../../models/user_models.dart';
import '../../services/auth.dart';
import '../../shared/theme_helper.dart';
import '../../widgets/header_widget.dart';
import '../home_screen.dart';
import '../user/user_setting.dart';
import 'add_menu_screen.dart';

class RestaurantHome extends StatefulWidget {
  const RestaurantHome({Key? key, required this.user}) : super(key: key);

  final Users? user;

  @override
  State<RestaurantHome> createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends State<RestaurantHome> with SingleTickerProviderStateMixin {
  final double _drawerIconSize = 24;
  final double _drawerFontSize = 17;
  double _balance = 0;

  final AuthService _auth = AuthService();

  late AnimationController _animationController;
  late Animation<Offset> _headerOffsetAnimation;
  late Animation<Offset> _balanceOffsetAnimation;

  @override
  void initState() {
    super.initState();
    getBalance();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _headerOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _balanceOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.decelerate,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void getBalance() {
    final userStream = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user!.uid)
        .snapshots();

    userStream.listen((event) {
      if (event.data() != null && event.data()!.containsKey('balance')) {
        setState(() {
          _balance = event.data()!['balance'].toDouble();
        });
      }
    });
  }

  Future<Row> rating(String restaurantID) async {
    final ratingSnapshot = await FirebaseFirestore.instance
        .collection('restaurant')
        .doc(restaurantID)
        .collection('Ratings')
        .get();

    double sumRatings = 0;
    int totalRatings = 0;

    for (final ratingDoc in ratingSnapshot.docs) {
      if (ratingDoc.exists) {
        final rating = ratingDoc.data()['rating'] as double;
        sumRatings += rating;
        totalRatings++;
      }
    }

    final double averageRatings = totalRatings > 0 ? sumRatings / totalRatings : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RatingBar.builder(
          initialRating: averageRatings,
          minRating: 1,
          maxRating: 5,
          allowHalfRating: true,
          ignoreGestures: true,
          itemCount: 5,
          itemSize: 20,
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {},
        ),
        Text(
          '($totalRatings)',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        )
      ],
    );
  }

  void checkPinIsNull() async {
    final user = FirebaseAuth.instance.currentUser;
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final pinIsNull = userSnapshot.data()?['PIN'] == null;

    if (pinIsNull) {
      final completer = Completer<bool>();

      CoolAlert.show(
        context: context,
        type: CoolAlertType.confirm,
        title: "PIN needed",
        text: 'Please set your PIN to use this feature',
        confirmBtnText: 'Yes',
        cancelBtnText: 'No',
        confirmBtnColor: Colors.green,
        onConfirmBtnTap: () {
          completer.complete(true);
        },
        onCancelBtnTap: () {
          completer.complete(false);
        },
      );

      final shouldNavigate = await completer.future;
      if (shouldNavigate) {
        Get.to(() => UserSetting(user: widget.user), transition: Transition.rightToLeftWithFade);
      }
    } else {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Restaurant Home",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 1.0],
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.2),
                Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              ],
            ),
          ),
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 1.0],
                    colors: [ Theme.of(context).primaryColor,Theme.of(context).colorScheme.secondary,],
                  ),
                ),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: const Text("Food Delivery",
                    style: TextStyle(fontSize: 25,color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Home',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Get.offAll(() => const Home(), transition: Transition.rightToLeft);
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.history_edu_outlined, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Orders',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Get.to(() => RestOrderHistory(user: widget.user), transition: Transition.rightToLeftWithFade);
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.settings, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Settings',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Get.to(() => RestSetting(user: widget.user), transition: Transition.rightToLeftWithFade);
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.restaurant_rounded, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Add Menu',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Get.to(() => AddMenu(user: widget.user), transition: Transition.rightToLeftWithFade);
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.edit_document, size: _drawerIconSize, color: Theme.of(context).colorScheme.secondary,),
                title: Text('View Menu', style: TextStyle(fontSize: _drawerFontSize, color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Get.to(() => ViewMenuScreen(user: widget.user), transition: Transition.rightToLeftWithFade);
                },
              ),
              Divider(
                color: Theme.of(context).primaryColor,
                height: 1,
              ),
              ListTile(
                leading: Icon(Icons.logout_rounded, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Logout',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () async {
                  await _auth.SignOut();
                  Get.offAll(() => const Wrapper(), transition: Transition.fade);
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Builder(
          builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: _headerOffsetAnimation.value * 100,
                          child: const SizedBox(
                            height: 100,
                            child: HeaderWidget(100, false, Icons.house_rounded),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: _balanceOffsetAnimation.value * 100,
                          child: Container(
                            height: 120,
                            margin: const EdgeInsets.only(
                              left: 30,
                              right: 30,
                              bottom: 15,
                              top: 15,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(
                                top: 15,
                                left: 15,
                                right: 15,
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Balance',
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        _balance.toStringAsFixed(2),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                          fontSize: 40,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 15),
                                    decoration: ThemeHelper().buttonBoxDecoration(context),
                                    child: ElevatedButton(
                                      style: ThemeHelper().buttonStyle(),
                                      onPressed: checkPinIsNull,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                        child: Text(
                                          'Cash out'.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your Rating",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FutureBuilder<Row>(
                  future: rating(widget.user!.uid.toString()),
                  builder: (BuildContext context, AsyncSnapshot<Row> ratingSnapshot) {
                    if (ratingSnapshot.hasError) {
                      return Text('Error: ${ratingSnapshot.error}');
                    }
                    if (!ratingSnapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    return ratingSnapshot.data!;
                  },
                ),
                const Text(
                  "Incoming Order",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Order')
                        .where('restID', isEqualTo: widget.user!.uid.toString())
                        .where('status', isEqualTo: 'Received')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final orders = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final orderDoc = orders[index].data() as Map<String, dynamic>;
                          final OrderModel order = OrderModel.fromJson(orderDoc);

                          return GestureDetector(
                            onTap: () {
                              Get.to(() => RestViewOrder(order: order), transition: Transition.size, duration: const Duration(seconds: 1));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Order ID: ${orderDoc['orderID']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Status: ${orderDoc['status']}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                        // Add other relevant order details here
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
