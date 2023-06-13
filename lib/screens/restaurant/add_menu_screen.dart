import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/screens/restaurant/restaurant_order_history.dart';
import 'package:fyp_2/screens/restaurant/restaurant_profile_screen.dart';
import 'package:fyp_2/screens/restaurant/view_menu.dart';
import 'package:fyp_2/screens/wrapper.dart';
import 'package:fyp_2/services/database.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:motion_toast/motion_toast.dart';

import '../../models/user_models.dart';
import '../../services/auth.dart';
import '../../shared/theme_helper.dart';
import '../../widgets/header_widget.dart';
import '../home_screen.dart';

class AddMenu extends StatefulWidget {
  // const AddMenu({Key? key}) : super(key: key);

  const AddMenu({Key? key,required this.user}) : super(key: key);
  final Users? user;

  @override
  State<AddMenu> createState() => _AddMenuState();
}

class _AddMenuState extends State<AddMenu> with SingleTickerProviderStateMixin {
  final double  _drawerIconSize = 24;
  final double _drawerFontSize = 17;
  final _formKey = GlobalKey<FormState>();

  final AuthService _auth = AuthService();

  File? _image;
  var imageUrl = "";
  var foodName = "";
  var foodDesc = "";
  double amount = 0.00;

  late AnimationController _animationController;
  late Animation<Offset> _headerOffsetAnimation;

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Item",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace:Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary,]
              )
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration:BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 1.0],
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.2),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                  ]
              )
          ) ,
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 1.0],
                    colors: [ Theme.of(context).primaryColor,Theme.of(context).colorScheme.secondary,],
                  ),
                ),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: const Text("Food Delivery",
                    style: TextStyle(fontSize: 25,color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Home',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Get.offAll(() => const Home(), transition: Transition.rightToLeft);
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.history_edu_outlined, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Orders',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Get.to(() => RestOrderHistory(user: widget.user), transition: Transition.rightToLeftWithFade);
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.verified_user_sharp, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Profile Page',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Get.to(() => RestaurantProfile(user: widget.user), transition: Transition.rightToLeftWithFade);
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.restaurant_rounded, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Add Menu',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Get.to(() => AddMenu(user: widget.user), transition: Transition.rightToLeftWithFade);
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.edit_document, size: _drawerIconSize, color: Theme.of(context).colorScheme.secondary,),
                title: Text('View Menu', style: TextStyle(fontSize: _drawerFontSize, color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Get.to(() => ViewMenuScreen(user: widget.user), transition: Transition.rightToLeftWithFade);
                },
              ),
              Divider(
                color: Theme.of(context).primaryColor,
                height: 1,
              ),
              ListTile(
                leading: Icon(Icons.logout_rounded, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Logout',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () async {
                  await _auth.SignOut();
                  Get.offAll(() => const Wrapper(), transition: Transition.fade);
                },
              ),
            ],
          ),
        ),
      ),
      body: Builder(
        builder: (context) => SingleChildScrollView(
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
                margin: const EdgeInsets.only(top: 30),
                width: 400,
                child: Column(
                  children: [
                    Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Add Details',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 27),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Container(
                              height:200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 20,
                                    offset: Offset(5, 5),
                                  ),
                                ],
                              ),
                              child: _image != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.file(_image!,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : const Center(
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 80.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30,),
                            Container(
                              decoration: ThemeHelper().buttonBoxDecoration(context),
                              child: ElevatedButton(
                                style: ThemeHelper().buttonStyle(),
                                child: const Padding(
                                  padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                                  child: Icon(Icons.add_photo_alternate, color: Colors.white,),
                                ),
                                onPressed: () async {
                                  ImagePicker imagePicker = ImagePicker();
                                  XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
                                  if(file == null) return;
                                  setState(() {
                                    _image = File(file.path);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 350,
                              child: TextFormField( //add food name
                                keyboardType: TextInputType.text,
                                maxLength: 30,
                                style: const TextStyle(fontFamily: 'Raleway', color: Colors.black),
                                decoration: const InputDecoration(
                                  labelText: "Food Name",
                                  labelStyle:
                                  TextStyle(fontWeight: FontWeight.w200, fontSize: 20),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value){
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a name';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() => foodName = value);
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 350,
                              child: TextFormField( //add food description
                                keyboardType: TextInputType.text,
                                maxLength: 250,
                                style: const TextStyle(fontFamily: 'Raleway', color: Colors.black),
                                decoration: const InputDecoration(
                                  labelText: "Food Description",
                                  labelStyle:
                                  TextStyle(fontWeight: FontWeight.w200, fontSize: 20),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value){
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() => foodDesc = value);
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 350,
                              child: TextFormField( //add price
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontFamily: 'Raleway', color: Colors.black),
                                decoration: const InputDecoration(
                                  labelText: "Price",
                                  labelStyle:
                                  TextStyle(fontWeight: FontWeight.w200, fontSize: 20),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value){
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a value';
                                  }

                                  const pattern = r'^\d+(\.\d{1,2})?$';
                                  final regExp = RegExp(pattern);

                                  if (!regExp.hasMatch(value)) {
                                    return 'Invalid input. Please enter a valid number with at most 2 decimal places.';
                                  }

                                  return null; // Return null if the input is valid
                                },
                                onChanged: (value) {
                                  amount = double.parse(value);
                                },
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  decoration: ThemeHelper().buttonBoxDecoration(context),
                                  child: ElevatedButton(
                                    style: ThemeHelper().buttonStyle(),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                                      child: Text(
                                        "Add Menu".toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()){
                                        try{
                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) => const Center(child: CircularProgressIndicator())
                                          );

                                          String filename = DateTime.now().millisecondsSinceEpoch.toString();

                                          Reference referenceRoot = FirebaseStorage.instance.ref().child('foodimages');
                                          Reference referenceImageToUpload = referenceRoot.child(filename);

                                          await referenceImageToUpload.putFile(_image!);
                                          imageUrl = await referenceImageToUpload.getDownloadURL();

                                          await MenuDatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).setMenu(widget.user!.name, imageUrl, foodName, foodDesc, amount);
                                          if (context.mounted){
                                            MotionToast.success(
                                              title:  const Text("Menu Added"),
                                              description:  const Text("Successfully added menu"),
                                              animationDuration: const Duration(seconds: 1),
                                              toastDuration: const Duration(seconds: 2),
                                            ).show(context);
                                          }
                                        }catch(e){
                                          MotionToast.error(
                                            title:  const Text("Error adding menu"),
                                            description:  Text(e.toString()),
                                            animationDuration: const Duration(seconds: 1),
                                            toastDuration: const Duration(seconds: 2),
                                          ).show(context);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                    ),
                  ],
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}
