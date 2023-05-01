import 'package:flutter/material.dart';
import 'package:fyp_2/screens/user_auth_screen.dart';
import 'package:fyp_2/screens/user_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:fyp_2/models/user_models.dart';


class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<Users?>(context);

    if (user == null) {
      return UserAuth();
    }else {
      return UserHome();
    }
  }
}
