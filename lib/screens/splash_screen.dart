import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fyp_2/screens/wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  navigateTo() async {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Wrapper()), (route) => false);
    });
  }

  @override
  void initState() {
    navigateTo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.secondary, Theme.of(context).primaryColor],
            begin: const FractionalOffset(0, 0),
            end: const FractionalOffset(1.0, 0.0),
            stops: const [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 80,
            ),
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 2.0,
                      offset: const Offset(5.0, 3.0),
                      spreadRadius: 2.0,
                    )
                  ]
              ),
              child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 3, end: 1),
                  duration: const Duration(seconds: 1),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 2, end: 0),
                        duration: const Duration(seconds: 5),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.rotate(
                              angle: value,
                              child: const Icon(Icons.restaurant_menu_outlined, size: 128,)
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [Colors.amber.shade400, Colors.amber.shade700],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds);
              },
              child: const Text(
                "Food Delivery UTM",
                style: TextStyle(
                  fontFamily: 'assets/font/Roboto',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}