import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/screens/rider/rider_order_history.dart';
import 'package:fyp_2/screens/rider/rider_setting.dart';
import 'package:fyp_2/screens/rider/view_order.dart';
import 'package:fyp_2/services/database.dart';
import 'package:get/get.dart';
import 'package:motion_toast/motion_toast.dart';

import '../../models/order_model.dart';
import '../../models/user_models.dart';
import '../../services/auth.dart';
import '../../shared/theme_helper.dart';
import '../../widgets/header_widget.dart';
import '../home_screen.dart';
import '../restaurant/rest_cashout_screen.dart';
import '../wrapper.dart';

class RiderHome extends StatefulWidget {
  final Users? user;

  const RiderHome({Key? key, required this.user}) : super(key: key);

  @override
  State<RiderHome> createState() => _RiderHomeState();
}

class _RiderHomeState extends State<RiderHome> with SingleTickerProviderStateMixin {
  final double _drawerIconSize = 24;
  final double _drawerFontSize = 17;
  final AuthService _auth = AuthService();
  OrderModel? _currentOrder;
  double _balance = 0;

  late AnimationController _animationController;
  late Animation<Offset> _headerOffsetAnimation;
  late Animation<Offset> _balanceOffsetAnimation;

  @override
  void initState() {
    super.initState();
    getBalance();
    checkOrder();

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

  void checkOrder() async {
    final isCurrentOrder = await RiderDatabaseService(uid: widget.user!.uid.toString()).checkCurrentOrder();

    if (isCurrentOrder) {
      final order = await RiderDatabaseService(uid: widget.user!.uid.toString()).getCurrentOrder();

      setState(() {
        _currentOrder = order;
      });
    } else {
      // If there is no current order, set _currentOrder to null
      setState(() {
        _currentOrder = null;
      });
    }
  }

  void _acceptOrder(OrderModel order) async {
    final isCurrentOrder = await RiderDatabaseService(uid: widget.user!.uid.toString()).checkCurrentOrder();

    if (isCurrentOrder) {
      if (context.mounted){
        MotionToast.error(
          title: const Text("Error taking order"),
          description: const Text("Please complete current order"),
          animationDuration: const Duration(seconds: 1),
          toastDuration: const Duration(seconds: 2),
        ).show(context);
      }
    } else {

      try{
        await OrderDatabaseService().assignOrderToRider(order, widget.user!.uid.toString());
        setState(() {
          order.riderID = widget.user!.uid.toString();
        });
        await RiderDatabaseService(uid: widget.user!.uid.toString()).takeOrder(order);

        if (context.mounted){
          MotionToast.success(
            title:  const Text("Order Taken"),
            description:  const Text("Please Complete the order"),
            animationDuration: const Duration(seconds: 1),
            toastDuration: const Duration(seconds: 2),
          ).show(context);
        }

        setState(() {
          _currentOrder = order;
        });
      }catch(e){
        if (context.mounted){
          MotionToast.error(
            title:  const Text("Error taking order"),
            description:  Text(e.toString()),
            animationDuration: const Duration(seconds: 1),
            toastDuration: const Duration(seconds: 2),
          ).show(context);
        }
      }
    }
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
        Get.to(() => RiderSetting(user: widget.user), transition: Transition.rightToLeftWithFade);
      }
    } else {
      Get.to(() => RestCashOut(user: widget.user), transition: Transition.rightToLeftWithFade);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rider Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
          decoration:BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 1.0],
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.2),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                  ]
              )
          ) ,
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
                leading: Icon(Icons.settings, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Settings',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Get.to(() => RiderSetting(user: widget.user), transition: Transition.rightToLeftWithFade);
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
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
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
                const SizedBox(height: 20),
                const Text(
                  'Current Order',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _currentOrder != null
                    ? GestureDetector(
                  onTap: () {
                    Get.to(() => ViewOrderScreen(order: _currentOrder, onOrderStatusUpdated: () {
                    setState(() {
                    checkOrder();
                    });
                    },), transition: Transition.size, duration: const Duration(seconds: 1));
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey[200],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text('Delivery Address: ${_currentOrder!.address}'),
                        Text('Delivery Fee: RM${_currentOrder!.deliveryFee.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                )
                    : const SizedBox(),
                const SizedBox(height: 20),
                const Text(
                  'Orders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Order')
                      .where('riderID', isEqualTo: null)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
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


                        if (order.riderID == null) {
                          return Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.grey[200],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text('Delivery Address: ${order.address}'),
                                Text('Delivery Fee: RM${order.deliveryFee.toStringAsFixed(2)}'),
                                ElevatedButton(
                                  onPressed: () => _acceptOrder(order),
                                  child: const Text('Accept Order'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),

    );
  }
}