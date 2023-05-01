import 'package:flutter/material.dart';
import 'package:fyp_2/services/auth.dart';

class UserHome extends StatelessWidget {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[600],
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.pink[900],
        elevation: 0.0,
        actions: <Widget>[
          ElevatedButton.icon(
            icon: Icon(Icons.person),
            label: Text('Log Out'),
            onPressed: () async {
              await _auth.SignOut();
            },
          )
        ],
      ),
    );
  }
}
