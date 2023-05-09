import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/screens/splash_screen.dart';
import 'package:fyp_2/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:fyp_2/models/user_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final Color? _primaryColor = Colors.pink[900];
  final Color? _accentColor = Colors.pink[600];

  @override
  Widget build(BuildContext context) {
    return StreamProvider<Users?>.value(
      catchError: (_, __){},
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: _primaryColor,
          scaffoldBackgroundColor: Colors.grey.shade100, colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey).copyWith(secondary: _accentColor),
        ),
        home: SplashScreen(title: "Food Delivery"),
      ),
    );
  }
}
