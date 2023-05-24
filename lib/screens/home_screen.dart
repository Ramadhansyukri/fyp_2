import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/models/user_models.dart';
import 'package:fyp_2/screens/restaurant/restaurant_home_screen.dart';
import 'package:fyp_2/screens/rider/rider_home_screen.dart';
import 'package:fyp_2/screens/user/user_home_screen.dart';
import 'package:fyp_2/screens/wrapper.dart';
import 'package:fyp_2/services/database.dart';

import '../services/auth.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String uid = FirebaseAuth.instance.currentUser!.uid;
  final AuthService _auth = AuthService();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Users?>(
        future: UserDatabaseService(uid: uid).getUser(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError){
            return Text("Something went wrong! ${snapshot.error.toString()}");
          } else if (snapshot.hasData) {
            final Users user = snapshot.data!;
            if("${user.usertype}" == "Customer"){
              return UserHome(user: user);
            }else if("${user.usertype}" == "Rider"){
              return RiderHome(user: user);
            }else {
              return RestaurantHome(user: user);
            }
          } else {
            return Center(
              child: Column(
                children: [
                  Center(
                    child: ElevatedButton(
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                          child: Text(
                            "Log Out".toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              ),
                            ),
                          ),
                      onPressed: () async {
                      FirebaseAuth.instance.signOut();
                      Navigator.push( context, MaterialPageRoute(builder: (context) => const Wrapper()), );
                      },
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                        child: Text(
                          "Delete Account".toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        _auth.deleteAccount(uid,snapshot.data!.usertype);
                        Navigator.push( context, MaterialPageRoute(builder: (context) => const Wrapper()), );
                      },
                    ),
                  ),
                ],
              )
            );
          }
        },
      ),
    );

  }
}
