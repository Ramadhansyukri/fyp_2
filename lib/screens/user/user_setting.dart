import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/screens/home_screen.dart';
import 'package:fyp_2/screens/user/user_profile_screen.dart';
import 'package:fyp_2/screens/wrapper.dart';
import 'package:get/get.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:bcrypt/bcrypt.dart';

import '../../models/user_models.dart';
import '../../services/auth.dart';
import '../../widgets/header_widget.dart';
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
    super.dispose();
  }

  Future<void> _setPin() async {
    final controller = InputController();
    await screenLockCreate(
      context: context,
      inputController: controller,
      onConfirmed: (matchedText) async {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.user!.uid);

        final String hashedPin = BCrypt.hashpw(matchedText, BCrypt.gensalt());

        await userDoc.update({'PIN': hashedPin});
        setState(() {
          _isPinEnabled = true;
        });
        Get.back();
      },
      footer: TextButton(
        onPressed: () {
          controller.unsetConfirmed();
        },
        child: const Text('Reset input'),
      ),
    );
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
                                  final controller = InputController();
                                  await screenLockCreate(
                                    context: context,
                                    inputController: controller,
                                    onConfirmed: (matchedText) async {
                                      final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.user!.uid);
                                      final String hashedPin = BCrypt.hashpw(matchedText, BCrypt.gensalt());
                                      await userDoc.update({'PIN': hashedPin});
                                      setState(() {
                                        _isPinEnabled = true;
                                      });
                                      Get.back();
                                    },
                                    footer: TextButton(
                                      onPressed: () {
                                        controller.unsetConfirmed();
                                      },
                                      child: const Text('Reset input'),
                                    ),
                                  );
                                } else {
                                  final controller = InputController();
                                  await screenLockCreate(
                                    context: context,
                                    inputController: controller,
                                    onConfirmed: (matchedText) async {
                                      final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.user!.uid);
                                      final userData = await userDoc.get();
                                      final storedPin = userData.get('PIN') as String;
                                      final bool isPinValid = BCrypt.checkpw(matchedText, storedPin);
                                      if (isPinValid) {
                                        await userDoc.update({'PIN': null});
                                        setState(() {
                                          _isPinEnabled = false;
                                        });
                                        Get.back();
                                      } else {
                                        // Show error message or perform appropriate actions
                                      }
                                    },
                                    footer: TextButton(
                                      onPressed: () {
                                        controller.unsetConfirmed();
                                      },
                                      child: const Text('Reset input'),
                                    ),
                                  );
                                }
                              },
                            ),
                            if (_isPinEnabled)
                              ListTile(
                                title: const Text('Change PIN'),
                                onTap: () {
                                  _setPin();
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
}
