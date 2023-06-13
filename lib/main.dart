import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fyp_2/screens/splash_screen.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Stripe.publishableKey = 'pk_test_51NDeeAHKlJGYNRxoo2zqGxVfNNvpvE72m327faEPgQ5XqYJraiM1Wukv3lZohRzaWRywSPTt5flHLV2X3aihQyfF00dKVphJJ4';
  await Stripe.instance.applySettings();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final Color? _primaryColor = Colors.pink[900];
  final Color? _accentColor = Colors.pink[600];

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        theme: ThemeData(
          primaryColor: _primaryColor,
          scaffoldBackgroundColor: Colors.grey.shade100, colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey).copyWith(secondary: _accentColor),
        ),
        home: const SplashScreen(),
      );
  }
}
