import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:motion_toast/motion_toast.dart';
import '../../models/order_model.dart';

class UserViewOrder extends StatefulWidget {
  const UserViewOrder({Key? key, required this.order}) : super(key: key);

  final OrderModel? order;

  @override
  State<UserViewOrder> createState() => _UserViewOrderState();
}

class _UserViewOrderState extends State<UserViewOrder> {
  late Future<DocumentSnapshot> _userFuture;
  late Future<DocumentSnapshot> _restaurantFuture;
  late Future<DocumentSnapshot> _riderFuture;
  late Future<DocumentSnapshot> _orderFuture;
  bool _isRated = false;
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser(widget.order!.userID);
    _restaurantFuture = _fetchRestaurant(widget.order!.restID);
    _riderFuture = _fetchRider(widget.order!.riderID.toString());
    _orderFuture = _fetchOrder(widget.order!.orderID);
  }

  Future<DocumentSnapshot> _fetchUser(String userID) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('customer')
        .doc(userID)
        .get();
    return userDoc;
  }

  Future<DocumentSnapshot> _fetchRestaurant(String restaurantID) async {
    final restaurantDoc = await FirebaseFirestore.instance
        .collection('restaurant')
        .doc(restaurantID)
        .get();
    return restaurantDoc;
  }

  Future<DocumentSnapshot> _fetchRider(String riderID) async {
    final riderDoc = await FirebaseFirestore.instance
        .collection('rider')
        .doc(riderID)
        .get();
    return riderDoc;
  }

  Future<DocumentSnapshot> _fetchOrder(String orderID) async {
    final orderDoc = await FirebaseFirestore.instance
        .collection('Order')
        .doc(orderID)
        .get();
    return orderDoc;
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rate Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please rate your order'),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40,
                unratedColor: Colors.amber.withAlpha(50),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _submitRating(widget.order!.orderID);
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _submitRating(String orderId) {
    if (_isRated) {
      return;
    }

    FirebaseFirestore.instance.collection('Order').doc(orderId)
        .update({
      'rating': _rating,
    }).then((_) {
      setState(() {
        _isRated = true;
      });
      MotionToast.success(
        title: const Text("Rating submitted"),
        description: const Text("Rating saved"),
        animationDuration: const Duration(seconds: 1),
        toastDuration: const Duration(seconds: 2),
      ).show(context);

      String restaurantId = widget.order!.restID;
      FirebaseFirestore.instance.collection('restaurant').doc(restaurantId)
          .collection('Ratings').doc(orderId)
          .set({'rating': _rating});
    }).catchError((error) {
      MotionToast.error(
        title: const Text("Error rating order"),
        description: Text(error.toString()),
        animationDuration: const Duration(seconds: 1),
        toastDuration: const Duration(seconds: 2),
      ).show(context);
    });
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
          'Order Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
          future: Future.wait([
            _userFuture,
            _restaurantFuture,
            _riderFuture,
            _orderFuture,
          ]),
          builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            }

            final userDoc = snapshot.data![0];
            final restaurantDoc = snapshot.data![1];
            final riderDoc = snapshot.data![2];
            final orderDoc = snapshot.data![3];

            // Fetch the item documents from the "item" subcollection within "OrderTaken"
            final itemDocs = orderDoc.reference.collection('items').get();

            // Use the fetched data to display order details
            return Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey[200],
                    ),
                    //padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    child: ListView(
                      //padding: const EdgeInsets.all(5),
                      children: [
                        ListTile(
                          title: const Text(
                            'Order ID:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(orderDoc.id),
                        ),
                        ListTile(
                          title: const Text(
                            'Order Date:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(orderDoc['dateTime'].toDate().toString()),
                        ),
                        ListTile(
                          title: const Text(
                            'Status:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(orderDoc['status']),
                        ),
                        ListTile(
                          title: const Text(
                            'Customer Name:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(userDoc['name']),
                        ),
                        ListTile(
                          title: const Text(
                            'Restaurant Name:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(restaurantDoc['name']),
                        ),
                        ListTile(
                          title: const Text(
                            'Rider:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(riderDoc['name']),
                        ),
                        ListTile(
                          title: const Text(
                            'Restaurant Address:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(restaurantDoc['address']),
                        ),
                        ListTile(
                          title: const Text(
                            'Delivery Address:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(orderDoc['address']),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Items:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FutureBuilder<QuerySnapshot>(
                          future: itemDocs,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData) {
                              return const Text('No items available');
                            }

                            final items = snapshot.data!.docs;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];

                                if (item['instruction'] != "") {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(item['name']),
                                        subtitle: Text(
                                          'RM ${item['price'].toStringAsFixed(2)} x ${item['quantity']}',
                                        ),
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(item['imageUrl']),
                                        ),
                                      ),
                                      ListTile(
                                        title: const Text(
                                          'Instruction:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(item['instruction']),
                                      ),
                                    ],
                                  );
                                } else {
                                  return ListTile(
                                    title: Text(item['name']),
                                    subtitle: Text(
                                      'RM ${item['price'].toStringAsFixed(2)} x ${item['quantity']}',
                                    ),
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(item['imageUrl']),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.grey[200],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subtotal: RM${(orderDoc['total'] - orderDoc['deliveryFee']).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Delivery Fee: RM${orderDoc['deliveryFee'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total Fee: RM${orderDoc['total'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: orderDoc['rating'] == null ? _showRatingDialog : null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: orderDoc['rating'] == null ? Colors.pink[900] : Colors.grey,
                        ),
                        child: const Text('Rate'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
