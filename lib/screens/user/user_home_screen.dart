import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/screens/user/topup.dart';
import 'package:fyp_2/screens/user/user_profile_screen.dart';
import 'package:fyp_2/screens/user/view_restaurant_screen.dart';
import 'package:fyp_2/screens/wrapper.dart';
import 'package:fyp_2/services/auth.dart';

import '../../models/user_models.dart';
import '../../shared/theme_helper.dart';
import '../../widgets/header_widget.dart';
import 'cart_screen.dart';

class UserHome extends StatefulWidget {
  //const RiderHome({Key? key}) : super(key: key);

  const UserHome({Key? key,required this.user}) : super(key: key);

  final Users? user;

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {

  final double  _drawerIconSize = 24;
  final double _drawerFontSize = 17;

  final AuthService _auth = AuthService();
  final db = FirebaseFirestore.instance;
  double _balance = 0;

  @override
  void initState() {
    getBalance();
    super.initState();
  }

  void getBalance(){
    final userStream = db.collection("users").doc(widget.user!.uid).snapshots();

    userStream.listen((event) {
      setState(() {
        _balance = event.data()!['balance'].toDouble();
      });
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text("Home",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace:Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary,]
              )
          ),
        ),
        actions: <Widget>[
          IconButton(
              onPressed: (){
                Navigator.push( context, MaterialPageRoute(builder: (context) => CartScreen(user: widget.user)),);
              },
              icon: const Icon(Icons.shopping_cart)
          )
        ],
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
                leading: Icon(Icons.verified_user_sharp, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Profile Page',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Navigator.push( context, MaterialPageRoute(builder: (context) => UserProfile(user: widget.user,)), );
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
                  const SizedBox(height: 100, child: HeaderWidget(100,false,Icons.house_rounded),),
                  Container(
                    height: 120,
                    margin: const EdgeInsets.only(left: 30, right: 30, bottom: 15, top: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Balance",
                                maxLines: 1,
                                style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: Colors.black,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                              const SizedBox(height: 10,),
                              Text(
                                _balance.toStringAsFixed(2),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    color: Colors.black,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800
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
                                  "+ Reload".toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push( context, MaterialPageRoute(builder: (context) => TopUpScreen(user: widget.user,)), );

                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "All Restaurant".toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: db.collection('restaurant').snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                      return const Text('No data available');
                    }
                    else{
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final document = snapshot.data!.docs[index];
                          final restaurantID = document.id;
                          return GestureDetector(
                            onTap: (){
                              Navigator.push( context, MaterialPageRoute(builder: (context) => ViewRestaurant(restID: restaurantID, user: widget.user,)),);
                            },
                            child: Container(
                              height: 200,
                              margin: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white,
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Image.network(
                                      '${document['imageUrl']}',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                      left: 0,
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        height: 60,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(0),
                                            bottomLeft: Radius.circular(30),
                                            bottomRight: Radius.circular(30),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(width: 16), // Adjust the spacing as needed
                                            SizedBox(
                                              width: 250,
                                              child: Column(
                                                children: [
                                                  Text('${document['name']}',
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3,),
                                                  Text('${document['phone']}'),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
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
