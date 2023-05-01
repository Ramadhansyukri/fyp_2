import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/screens/wrapper.dart';
import 'package:fyp_2/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:fyp_2/models/user_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<Users?>.value(
      catchError: (_, __){},
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
        home: const Wrapper(),
      ),
    );
  }
}
