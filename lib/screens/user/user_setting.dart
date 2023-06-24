import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/screens/user/user_profile_screen.dart';
import 'package:get/get.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:bcrypt/bcrypt.dart' as encrypt;

import '../../models/user_models.dart';
import '../../services/auth.dart';
import '../../widgets/header_widget.dart';
import '../home_screen.dart';
import '../wrapper.dart';
import 'order_history.dart';

class UserSetting extends StatefulWidget {
  final Users? user;

  const UserSetting({Key? key, required this.user}) : super(key: key);

  @override
  State<UserSetting> createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting>
    with SingleTickerProviderStateMixin {
  final double _drawerIconSize = 24;
  final double _drawerFontSize = 17;

  final AuthService _auth = AuthService();

  late AnimationController _animationController;
  late Animation<Offset> _headerOffsetAnimation;

  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;
  late bool _isPinEnabled;

  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();

  /*Example for checking
  _onPasscodeEntered(String enteredPasscode) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.user!.uid);
    final userData = await userDoc.get();
    final storedPin = userData.get('PIN') as String;
    final bool isPinValid = encrypt.BCrypt.checkpw(enteredPasscode, storedPin);
    _verificationNotifier.add(isPinValid);
  }*/

  @override
  void initState() {
    super.initState();
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user!.uid)
        .snapshots();

    _isPinEnabled = false;

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
    _verificationNotifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 1.0],
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.2),
                Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              ],
            ),
          ),
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 1.0],
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: const Text(
                    "Food Delivery",
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home,
                    size: _drawerIconSize,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(
                  'Home',
                  style: TextStyle(
                      fontSize: _drawerFontSize,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                onTap: () {
                  Get.offAll(() => const Home(),
                      transition: Transition.rightToLeft);
                },
              ),
              Divider(
                color: Theme.of(context).primaryColor,
                height: 1,
              ),
              ListTile(
                leading: Icon(Icons.history_edu_outlined,
                    size: _drawerIconSize,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(
                  'Orders',
                  style: TextStyle(
                      fontSize: _drawerFontSize,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                onTap: () {
                  Get.to(() => UserOrderHistory(user: widget.user),
                      transition: Transition.rightToLeftWithFade);
                },
              ),
              Divider(
                color: Theme.of(context).primaryColor,
                height: 1,
              ),
              ListTile(
                leading: Icon(Icons.settings,
                    size: _drawerIconSize,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(
                  'Settings',
                  style: TextStyle(
                      fontSize: _drawerFontSize,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                onTap: () {
                  Get.to(() => UserSetting(user: widget.user),
                      transition: Transition.rightToLeftWithFade);
                },
              ),
              Divider(
                color: Theme.of(context).primaryColor,
                height: 1,
              ),
              ListTile(
                leading: Icon(Icons.logout_rounded,
                    size: _drawerIconSize,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(
                  'Logout',
                  style: TextStyle(
                      fontSize: _drawerFontSize,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                onTap: () async {
                  await _auth.SignOut();
                  Get.offAll(() => const Wrapper(),
                      transition: Transition.rightToLeftWithFade);
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: _headerOffsetAnimation.value * 100,
                  child: const SizedBox(
                    height: 100,
                    child: HeaderWidget(100, false, Icons.house_rounded),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    const Text(
                      'Account setting',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => UserProfile(user: widget.user));
                      },
                      child: const ListTile(
                        leading: Icon(Icons.account_circle),
                        title: Text('Profile Page'),
                        trailing: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Security',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: _userStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final userData = snapshot.data!.data();
                          _isPinEnabled = userData?['PIN'] != null;
                        }

                        return Column(
                          children: [
                            SwitchListTile(
                              title: const Text('PIN'),
                              subtitle: const Text('Enable PIN authentication'),
                              value: _isPinEnabled,
                              onChanged: (value) async {
                                if (value) {
                                  _setPIN(
                                    context,
                                    opaque: false,
                                    cancelButton: const Text(
                                      'Cancel',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                      semanticsLabel: 'Cancel',
                                    ),
                                  );
                                } else {
                                  _removePIN(
                                    context,
                                    opaque: false,
                                    cancelButton: const Text(
                                      'Cancel',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                      semanticsLabel: 'Cancel',
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
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
                passwordEnteredCallback: _setPasscode,
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
              ),
        ));
  }

  _removePIN(
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
              ),
        ));
  }

  _onPasscodeEntered(String enteredPasscode) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.user!.uid);
    final userData = await userDoc.get();
    final storedPin = userData.get('PIN') as String;
    final bool isPinValid = encrypt.BCrypt.checkpw(enteredPasscode, storedPin);
    _verificationNotifier.add(isPinValid);
    if (isPinValid) {
      await userDoc.update({'PIN': null});
      setState(() {
        _isPinEnabled = false;
      });
    }
  }

  _onPasscodeCancelled() {
    Navigator.maybePop(context);
  }

  _setPasscode(String enteredPasscode) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.user!.uid);

    final String hashedPin = encrypt.BCrypt.hashpw(enteredPasscode, encrypt.BCrypt.gensalt());

    await userDoc.update({'PIN': hashedPin});
    setState(() {
      _isPinEnabled = true;
    });
    Get.back();
  }
}
