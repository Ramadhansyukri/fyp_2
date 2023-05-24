import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class ViewRestaurant extends StatefulWidget {
  //const ViewRestaurant({Key? key}) : super(key: key);

  const ViewRestaurant({Key? key,required this.restID}) : super(key: key);

  final String restID;

  @override
  State<ViewRestaurant> createState() => _ViewRestaurantState();
}

class _ViewRestaurantState extends State<ViewRestaurant> {
  @override
  Widget build(BuildContext context) {

    final db = FirebaseFirestore.instance.collection('restaurant').doc(widget.restID);

    return Scaffold(
      appBar: AppBar(
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
          IconButton(onPressed: (){}, icon: const Icon(Icons.shopping_cart))
        ],
      ),
      body: Builder(
        builder: (context) => SizedBox(
          height: 1000,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "".toUpperCase(),
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
              const SizedBox(height: 40,),
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
                          return GestureDetector(
                            onTap: (){

                            },
                            child: Container(
                              height: 120,
                              //margin: const EdgeInsets.only(bottom: 15, top: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
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
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Align(
                                            alignment: Alignment.topCenter,
                                            child: Text(
                                              '${document['name']}',
                                              style: const TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${document['desc']}',
                                              maxLines: 3,
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
                                            alignment: Alignment.bottomCenter,
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
                                  ],
                                ),
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
