import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motion_toast/motion_toast.dart';
import '../../models/order_model.dart';
import '../../services/database.dart';

class RestViewOrder extends StatefulWidget {
  const RestViewOrder({Key? key, required this.order}) : super(key: key);

  final OrderModel? order;

  @override
  State<RestViewOrder> createState() => _RestViewOrderState();
}

class _RestViewOrderState extends State<RestViewOrder> {
  late Future<DocumentSnapshot> _userFuture;
  late Future<DocumentSnapshot> _orderFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser(widget.order!.userID);
    _orderFuture = _fetchOrder(widget.order!.orderID);
  }

  Future<DocumentSnapshot> _fetchUser(String userID) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('customer')
        .doc(userID)
        .get();
    return userDoc;
  }

  Future<DocumentSnapshot> _fetchOrder(String orderID) async {
    final orderDoc = await FirebaseFirestore.instance
        .collection('Order')
        .doc(orderID)
        .get();
    return orderDoc;
  }

  void _updateOrderStatus() {
    final orderDocRef = FirebaseFirestore.instance.collection('Order').doc(widget.order!.orderID);

    orderDocRef.update({'status': 'Ready'}).then((_) async {
      double subtotal = widget.order!.total - widget.order!.deliveryFee;

      await UserDatabaseService(uid: widget.order!.restID).addUserBalance(subtotal);

      setState(() {
        _orderFuture = _fetchOrder(widget.order!.orderID);
      });
      if (context.mounted){
        MotionToast.success(
          title:  const Text("Order Completed"),
          description:  const Text("Order Status Updated"),
          animationDuration: const Duration(seconds: 1),
          toastDuration: const Duration(seconds: 2),
        ).show(context);
      }
    }).catchError((error) {
      MotionToast.error(
        title:  const Text("Error updating status"),
        description:  Text(error.toString()),
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
            final orderDoc = snapshot.data![1];

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
                        onPressed: orderDoc['status'] == 'Received' ? _updateOrderStatus : null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: orderDoc['status'] == 'Received' ? Colors.green : Colors.grey,
                        ),
                        child: const Text('Ready'),
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
