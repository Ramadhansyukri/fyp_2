import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp_2/screens/verify_email_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:bcrypt/bcrypt.dart' as encrypt;

import '../services/auth.dart';
import '../shared/theme_helper.dart';
import '../widgets/header_widget.dart';
import 'wrapper.dart';
import 'package:get/get.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);
  /*const Biometric({Key? key,required this.user}) : super(key: key);
  final Users? user;*/

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  final AuthService _auth = AuthService();
  double headerHeight = 400;

  late AnimationController _animationController;
  late Animation<Offset> _headerOffsetAnimation;

  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();

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
    checkPinIsNull();
  }

  void checkPinIsNull() async {
    final user = FirebaseAuth.instance.currentUser;
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final pinIsNull = userSnapshot.data()?['PIN'] == null;

    if (pinIsNull) {
      Get.to(() => const VerifyEmail());
    } else {
      _setPIN(
        context,
        opaque: false,
        cancelButton: const Text(
          'Cancel',
          style: TextStyle(fontSize: 16, color: Colors.white),
          semanticsLabel: 'Cancel',
        ),
      );
    }
  }

  _setPIN(
      BuildContext context, {
        required bool opaque,
        CircleUIConfig? circleUIConfig,
        KeyboardUIConfig? keyboardUIConfig,
        required Widget cancelButton,
        List<String>? digits,
      }) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
                title: const Text(
                  'Enter App Passcode',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
                circleUIConfig: circleUIConfig,
                keyboardUIConfig: keyboardUIConfig,
                passwordEnteredCallback: _onPasscodeEntered,
                cancelButton: cancelButton,
                deleteButton: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  semanticsLabel: 'Delete',
                ),
                shouldTriggerVerification: _verificationNotifier.stream,
                backgroundColor: Colors.black.withOpacity(0.8),
                cancelCallback: _onPasscodeCancelled,
                digits: digits,
                passwordDigits: 6,
                bottomWidget: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await _authenticateWithBiometrics();
                      },// Trigger fingerprint authentication
                      child: const Icon(Icons.fingerprint), // Replace with your fingerprint icon
                    ),
                  ],
                ),
              ),
        ));
  }

  _onPasscodeEntered(String enteredPasscode) async {
    final user = FirebaseAuth.instance.currentUser;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    final userData = await userDoc.get();
    final storedPin = userData.get('PIN') as String;
    final bool isPinValid = encrypt.BCrypt.checkpw(enteredPasscode, storedPin);
    _verificationNotifier.add(isPinValid);
    if (isPinValid) {
      Get.to(() => const VerifyEmail());
    }
  }

  _onPasscodeCancelled() {
    Navigator.maybePop(context);
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
          Get.to(() => const VerifyEmail());
        }
      } on PlatformException catch (e) {
        await _auth.SignOut();
        Get.to(() => const Wrapper());
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
                            'Problem authenticate? Sign in',
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
                                Get.to(() => const Wrapper());
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
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            decoration: ThemeHelper().buttonBoxDecoration(context),
                            child: ElevatedButton(
                              style: ThemeHelper().buttonStyle(),
                              onPressed: () {
                                checkPinIsNull();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Authenticate'.toUpperCase(),
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
