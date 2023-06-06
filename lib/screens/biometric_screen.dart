import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp_2/screens/verify_email_screen.dart';
import 'package:local_auth/local_auth.dart';

import '../services/auth.dart';
import '../shared/theme_helper.dart';
import '../widgets/header_widget.dart';
import 'wrapper.dart';

class Biometric extends StatefulWidget {
  const Biometric({Key? key}) : super(key: key);
  /*const Biometric({Key? key,required this.user}) : super(key: key);
  final Users? user;*/

  @override
  State<Biometric> createState() => _BiometricState();
}

class _BiometricState extends State<Biometric> with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  final AuthService _auth = AuthService();
  double headerHeight = 400;

  late AnimationController _animationController;
  late Animation<Offset> _headerOffsetAnimation;

  @override
  void initState() {
    super.initState();
    _initializeData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _headerOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeData() async {
    await auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported ? _SupportState.supported : _SupportState.unsupported),
    );
    _authenticateWithBiometrics();
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_supportState == _SupportState.supported) {
      bool authenticated = false;
      try {
        authenticated = await auth.authenticate(
          localizedReason: 'Scan your fingerprint to enter the app',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
        if (authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VerifyEmail()),
          );
        }
      } on PlatformException catch (e) {
        await _auth.SignOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Wrapper()),
        );
        return;
      }
      if (!mounted) {
        return;
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VerifyEmail()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: _headerOffsetAnimation.value * headerHeight,
                  child: SizedBox(
                    height: headerHeight,
                    child: HeaderWidget(headerHeight, true, Icons.fingerprint_outlined),
                  ),
                );
              },
            ),
            SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Problem using biometric? Sign in',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            decoration: ThemeHelper().buttonBoxDecoration(context),
                            child: ElevatedButton(
                              style: ThemeHelper().buttonStyle(),
                              onPressed: () async {
                                await _auth.SignOut();
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Wrapper()),);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Sign In'.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
