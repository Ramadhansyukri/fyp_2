import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/screens/user/update_address.dart';
import 'package:fyp_2/screens/wrapper.dart';
import 'package:get/get.dart';

import '../../models/user_models.dart';
import '../../services/auth.dart';
import '../../services/database.dart';
import '../../widgets/header_widget.dart';

class UserProfile extends StatefulWidget {
  final Users? user;

  const UserProfile({Key? key, required this.user}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with SingleTickerProviderStateMixin {

  final AuthService _auth = AuthService();
  late String _userAddress = '';

  late AnimationController _animationController;
  late Animation<Offset> _headerOffsetAnimation;

  @override
  void initState() {
    super.initState();
    _fetchUserAddress();

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

  Future<void> _fetchUserAddress() async {
    // Implement your logic to fetch the user's address based on the user UID
    // For example:
    final userAddress = await UserDatabaseService(uid: widget.user!.uid.toString()).getUserAddress();
    setState(() {
      _userAddress = userAddress;
    });
  }

  void updateAddress(String newAddress) {
    setState(() {
      _userAddress = newAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile Page",
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
      body: SingleChildScrollView(
        child: Stack(
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
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 5, color: Colors.white),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "${widget.user?.name}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${widget.user?.usertype}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                          alignment: Alignment.topLeft,
                          child: const Text(
                            "User Information",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Card(
                          child: Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    ...ListTile.divideTiles(
                                      color: Colors.grey,
                                      tiles: [
                                        ListTile(
                                          leading: const Icon(Icons.email),
                                          title: const Text("Email"),
                                          subtitle: Text("${widget.user?.email}"),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.phone),
                                          title: const Text("Phone"),
                                          subtitle: Text("${widget.user?.phone}"),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.location_on),
                                          title: const Text("Address"),
                                          subtitle: Text(_userAddress.isNotEmpty ? _userAddress : "Set Address"),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              Get.to(() => AddressScreen(user: widget.user,updateAddress: updateAddress,), transition: Transition.rightToLeftWithFade);
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Add functionality for Edit Profile button
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Profile'),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.confirm,
                                      title: "Confirmation",
                                      text: 'Are you sure you want to delete your account?',
                                      confirmBtnText: 'Yes',
                                      cancelBtnText: 'No',
                                      confirmBtnColor: Colors.green,
                                      onConfirmBtnTap: () {
                                        _auth.deleteAccount(widget.user!.usertype);
                                        Get.offAll(() => const Wrapper(), transition: Transition.fade);
                                      }
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                icon: const Icon(Icons.delete),
                                label: const Text('Delete Account'),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}