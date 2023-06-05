import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyp_2/models/restaurant_model.dart';
import 'package:fyp_2/models/user_models.dart';
import 'package:fyp_2/services/database.dart';

import 'cart_screen.dart';

class ViewRestaurant extends StatefulWidget {
  const ViewRestaurant({Key? key, required this.restID, required this.user}) : super(key: key);

  final Users? user;
  final String restID;

  @override
  State<ViewRestaurant> createState() => _ViewRestaurantState();
}

class _ViewRestaurantState extends State<ViewRestaurant> {
  Restaurant? restaurant;
  Users? restaurantInfo;

  @override
  void initState() {
    super.initState();
    fetchRestaurant();
  }

  Future<void> fetchRestaurant() async {
    final restaurantData = await RestDatabaseService(uid: widget.restID).getRest();
    final restaurantData2 = await UserDatabaseService(uid: widget.restID).getUser();
    setState(() {
      restaurant = restaurantData;
      restaurantInfo = restaurantData2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance.collection('restaurant').doc(widget.restID);

    if (restaurant != null && restaurantInfo != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            restaurantInfo!.name,
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen(user: widget.user)));
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          ],
        ),
        body: Builder(
          builder: (context) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(restaurant!.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'Menu',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            StreamBuilder<QuerySnapshot>(
                              stream: db.collection('menu').snapshots(),
                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return const Center(child: Text('No data available'));
                                } else {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final document = snapshot.data!.docs[index];
                                      double price = document['price'];
                                      String showPrice = price.toStringAsFixed(2);
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                image: DecorationImage(
                                                  image: NetworkImage(document['imageUrl']),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    document['name'],
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    document['desc'],
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    showPrice,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                try {
                                                  await CartService(uid: widget.user!.uid).addToCart(
                                                    document['menuID'],
                                                    document['name'],
                                                    document['price'],
                                                    document['imageUrl'],
                                                    restaurant!.uid,
                                                    context,
                                                  );
                                                  Fluttertoast.showToast(
                                                    msg: 'Successfully added to cart',
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.BOTTOM,
                                                    fontSize: 16.0,
                                                    backgroundColor: Colors.green.withOpacity(0.8),
                                                    textColor: Colors.white,
                                                  );
                                                } catch (e) {
                                                  Fluttertoast.showToast(
                                                    msg: e.toString(),
                                                    fontSize: 16.0,
                                                    backgroundColor: Colors.redAccent.withOpacity(0.8),
                                                    textColor: Colors.white,
                                                  );
                                                }
                                              },
                                              icon: const Icon(Icons.add_shopping_cart),
                                              color: Colors.green,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
