import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/screens/rider/rider_profile_screen.dart';
import 'package:fyp_2/screens/rider/rider_view_order_history.dart';
import 'package:get/get.dart';

import '../../models/order_model.dart';
import '../../models/user_models.dart';
import '../../services/auth.dart';
import '../../widgets/header_widget.dart';
import '../home_screen.dart';
import '../wrapper.dart';

class RiderOrderHistory extends StatefulWidget {
  const RiderOrderHistory({Key? key, required this.user}) : super(key: key);

  final Users? user;

  @override
  State<RiderOrderHistory> createState() => _RiderOrderHistoryState();
}

class _RiderOrderHistoryState extends State<RiderOrderHistory> with SingleTickerProviderStateMixin {
  final double _drawerIconSize = 24;
  final double _drawerFontSize = 17;

  final AuthService _auth = AuthService();
  late AnimationController _animationController;
  late Animation<Offset> _headerOffsetAnimation;

  @override
  void initState() {
    super.initState();

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order History",
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
                  Get.off(() => const Home(), transition: Transition.rightToLeft);
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.verified_user_sharp, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Profile',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Get.to(() => RiderProfile(user: widget.user), transition: Transition.rightToLeftWithFade);
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.history_edu_outlined, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Orders',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Get.to(() => RiderOrderHistory(user: widget.user), transition: Transition.rightToLeftWithFade);
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
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
      body: Builder(
        builder: (context) => SingleChildScrollView(
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
                  SizedBox(
                    height: 70,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        "Your Order".toUpperCase(),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Order')
                    .where('riderID', isEqualTo: widget.user!.uid)
                    .where('status', isEqualTo: 'Delivered')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  } else {
                    final orders = snapshot.data!.docs;
                    if (orders.isEmpty) {
                      return const SizedBox();
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final orderDoc =
                          orders[index].data() as Map<String, dynamic>;
                          final OrderModel order =
                          OrderModel.fromJson(orderDoc);
                          return GestureDetector(
                            onTap: () {
                              Get.to(() => RiderViewOrder(order: order), transition: Transition.rightToLeft, opaque: false);
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order ID: ${order.orderID}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: ${order.status}',
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Total Amount: RM${order.total.toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
