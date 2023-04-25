import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/screens/home_screen.dart';
import 'package:fyp_2/screens/splash_screen.dart';
import 'package:fyp_2/screens/user_auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      routes: {
        UserAuthScreen.routeName: (ctx) => UserAuthScreen(),
        HomeScreen.routeName: (ctx) => HomeScreen(),
      },
    );
  }
}
