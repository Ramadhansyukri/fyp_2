import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/models/restaurant_model.dart';
import 'package:fyp_2/models/user_models.dart';
import 'package:fyp_2/services/database.dart';

import 'cart_screen.dart';


class ViewRestaurant extends StatefulWidget {
  //const ViewRestaurant({Key? key}) : super(key: key);

  const ViewRestaurant({Key? key,required this.restID}) : super(key: key);

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
          title: Text(restaurantInfo!.name,
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
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
                  Navigator.push( context, MaterialPageRoute(builder: (context) => const Cart()),);
                },
                icon: const Icon(Icons.shopping_cart)
            )
          ],
        ),
        body: Builder(
          builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: Stack(
                    children: [
                      ClipRRect(
                        child: Image.network(
                          restaurant!.imageUrl,
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ]
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: db.collection('menu').snapshots(),
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
                            double price = document['price'];
                            String showPrice = price.toStringAsFixed(2);
                            return Container(
                              height: 120,
                              width: MediaQuery.of(context).size.width,
                              //margin: const EdgeInsets.only(bottom: 15, top: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(30),
                                          child: Image.network(
                                            '${document['imageUrl']}',
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                    ),
                                    const SizedBox(width: 16),
                                    SizedBox(
                                      height: 120,
                                      width: 170,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                '${document['name']}',
                                                maxLines: 2,
                                                overflow: TextOverflow.visible,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '${document['desc']}',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color: Colors.grey
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Text(
                                                showPrice,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 100,
                                      width: 60,
                                      child: Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30.0),
                                                  ),
                                                ),
                                                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.add_shopping_cart,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onPressed: () async {

                                              },
                                            ),
                                          ],
                                        )
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
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
