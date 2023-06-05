import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyp_2/screens/rider/rider_order_history.dart';
import 'package:fyp_2/screens/rider/rider_profile_screen.dart';
import 'package:fyp_2/screens/rider/view_order.dart';
import 'package:fyp_2/services/database.dart';

import '../../models/order_model.dart';
import '../../models/user_models.dart';
import '../../services/auth.dart';
import '../../shared/theme_helper.dart';
import '../../widgets/header_widget.dart';
import '../home_screen.dart';
import '../wrapper.dart';

class RiderHome extends StatefulWidget {
  final Users? user;

  const RiderHome({Key? key, required this.user}) : super(key: key);

  @override
  State<RiderHome> createState() => _RiderHomeState();
}

class _RiderHomeState extends State<RiderHome> {
  final double _drawerIconSize = 24;
  final double _drawerFontSize = 17;
  final AuthService _auth = AuthService();
  OrderModel? _currentOrder;
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    getBalance();
    checkOrder();
  }

  void getBalance() {
    final userStream = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user!.uid)
        .snapshots();

    userStream.listen((event) {
      setState(() {
        _balance = event.data()!['balance'].toDouble();
      });
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
      Fluttertoast.showToast(
        msg: 'Please complete your current order',
        fontSize: 20.0,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        textColor: Colors.white,
      );
    } else {

      try{
        await OrderDatabaseService().assignOrderToRider(order, widget.user!.uid.toString());
        setState(() {
          order.riderID = widget.user!.uid.toString();
        });
        await RiderDatabaseService(uid: widget.user!.uid.toString()).takeOrder(order);

        Fluttertoast.showToast(
          msg: 'Order Accepted',
          fontSize: 20.0,
          backgroundColor: Colors.green.withOpacity(0.8),
          textColor: Colors.white,
        );

        setState(() {
          _currentOrder = order;
        });
      }catch(e){
        print(e.toString());
      }
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
                  Navigator.push( context, MaterialPageRoute(builder: (context) => const Home()), );
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.verified_user_sharp, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Profile',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Navigator.push( context, MaterialPageRoute(builder: (context) => RiderProfile(user: widget.user)), );
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.history_edu_outlined, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Orders',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Navigator.push( context, MaterialPageRoute(builder: (context) => RiderOrderHistory(user: widget.user)), );
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.logout_rounded, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Logout',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () async {
                  await _auth.SignOut();
                  Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => const Wrapper()), );
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.person_remove_rounded, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Delete Account',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () async {
                  await _auth.deleteAccount(widget.user!.usertype);
                  Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => const Wrapper()), );
                },
              ),
            ],
          ),
        ),
      ),
      body: Builder(
        builder: (context) => SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Stack(
                children: [
                  const SizedBox(
                    height: 100,
                    child: HeaderWidget(100, false, Icons.house_rounded),
                  ),
                  Container(
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
                              onPressed: () {
                                // TODO: Implement cash out functionality
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    onTap: () => Navigator.push( context, MaterialPageRoute(builder: (context) => ViewOrderScreen(order: _currentOrder)),),
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
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
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
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final orderDoc = orders[index].data() as Map<String, dynamic>;
                        final OrderModel order = OrderModel.fromJson(orderDoc);

                        if(order.riderID == null){
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
                        }else{
                          return Container();
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
