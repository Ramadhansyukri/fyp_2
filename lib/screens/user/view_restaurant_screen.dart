import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/models/restaurant_model.dart';
import 'package:fyp_2/models/user_models.dart';
import 'package:fyp_2/services/database.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:get/get.dart';

import '../../shared/theme_helper.dart';
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
                Get.to(() => CartScreen(user: widget.user), transition: Transition.cupertino, duration: const Duration(seconds: 1));
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
                                                    'RM$showPrice',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                _showModalBottomSheet(
                                                  context,
                                                  document['menuID'],
                                                  document['name'],
                                                  document['desc'],
                                                  document['price'],
                                                  document['imageUrl'],
                                                );
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

  void _showModalBottomSheet(BuildContext context, String foodID, String foodName, String foodDescription, double foodPrice, String foodImage) {
    String? specialInstructions = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.9,
        minChildSize: 0.32,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(foodImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    foodName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    foodDescription,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RM${foodPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Special Instructions',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3, // Adjust the number of lines as needed
                    onChanged: (value) {
                      setState(() {
                        specialInstructions = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      decoration: ThemeHelper().buttonBoxDecoration(context),
                      child: ElevatedButton(
                        style: ThemeHelper().buttonStyle(),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                          child: Text(
                            "Add to cart".toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            bool currentRest = false;
                            currentRest = await CartService(uid: widget.user!.uid).addToCart(
                              foodID,
                              foodName,
                              foodPrice,
                              foodImage,
                              restaurant!.uid,
                              specialInstructions,
                              context,
                            );
                            if(currentRest==true){
                              if (context.mounted){
                                MotionToast.success(
                                  title:  const Text("Added to cart"),
                                  description:  const Text("Successfully add item to cart"),
                                  animationDuration: const Duration(seconds: 1),
                                  toastDuration: const Duration(seconds: 2),
                                ).show(context);
                              }
                            }
                          } catch (e) {
                            MotionToast.error(
                              title:  const Text("Error adding to cart"),
                              description:  Text(e.toString()),
                              animationDuration: const Duration(seconds: 1),
                              toastDuration: const Duration(seconds: 2),
                            ).show(context);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
