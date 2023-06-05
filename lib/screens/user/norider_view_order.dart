import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart';

class UserOrderNoRider extends StatefulWidget {
  const UserOrderNoRider({Key? key, required this.order}) : super(key: key);

  final OrderModel? order;

  @override
  State<UserOrderNoRider> createState() => _UserOrderNoRiderState();
}

class _UserOrderNoRiderState extends State<UserOrderNoRider> {
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
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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

                                return ListTile(
                                  title: Text(item['name']),
                                  subtitle: Text(
                                    'RM ${item['price'].toStringAsFixed(2)} x ${item['quantity']}',
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(item['imageUrl']),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        // Add more details here as needed
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
