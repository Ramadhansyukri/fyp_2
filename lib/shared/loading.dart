import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100]?.withOpacity(0.5),
      child: Center(
        child: SpinKitFadingCircle(
          color: Colors.pink[600],
          size: 50.0,
        ),
      ),
    );
  }
}
