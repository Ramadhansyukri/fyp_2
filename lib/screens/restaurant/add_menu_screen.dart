import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyp_2/screens/restaurant/restaurant_home_screen.dart';
import 'package:fyp_2/screens/restaurant/restaurant_profile_screen.dart';
import 'package:fyp_2/screens/wrapper.dart';
import 'package:fyp_2/services/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/user_models.dart';
import '../../services/auth.dart';
import '../../shared/theme_helper.dart';
import '../home_screen.dart';

class AddMenu extends StatefulWidget {
  // const AddMenu({Key? key}) : super(key: key);

  const AddMenu({Key? key,required this.user}) : super(key: key);
  final Users? user;

  @override
  State<AddMenu> createState() => _AddMenuState();
}

class _AddMenuState extends State<AddMenu> {
  final double  _drawerIconSize = 24;
  final double _drawerFontSize = 17;
  final _formKey = GlobalKey<FormState>();

  final AuthService _auth = AuthService();

  File? _image;
  var imageUrl = "";
  var foodName = "";
  var foodDesc = "";
  double amount = 0.00;

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
                  Navigator.push( context, MaterialPageRoute(builder: (context) => const Home()), );
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.verified_user_sharp, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Profile Page',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () {
                  Navigator.push( context, MaterialPageRoute(builder: (context) => RestaurantProfile(user: widget.user)), );
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.logout_rounded, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Logout',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () async {
                  await _auth.SignOut();
                  Navigator.push( context, MaterialPageRoute(builder: (context) => const Wrapper()), );
                },
              ),
              Divider(color: Theme.of(context).primaryColor, height: 1,),
              ListTile(
                leading: Icon(Icons.person_remove_rounded, size: _drawerIconSize,color: Theme.of(context).colorScheme.secondary,),
                title: Text('Delete Account',style: TextStyle(fontSize: _drawerFontSize,color: Theme.of(context).colorScheme.secondary),),
                onTap: () async {
                  await _auth.deleteAccount(widget.user!.uid, widget.user!.usertype);
                  Navigator.push( context, MaterialPageRoute(builder: (context) => const Wrapper()), );
                },
              ),
            ],
          ),
        ),
      ),
      body: Builder(
        builder: (context) => SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 30.0),
              Container(
                color: Colors.white10,
                width: 400,
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                        child: Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Text(
                                  'Add Details',
                                  style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 27),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                                width: 350,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 400,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                      ),
                                      child: _image != null
                                          ? Center(
                                            child: Stack(
                                              children: [
                                                Image.file(_image!),
                                                IconButton(
                                                    onPressed: () async {
                                                      ImagePicker imagePicker = ImagePicker();
                                                      XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

                                                      if(file == null) return;

                                                      setState(() {
                                                        _image = File(file.path);
                                                      });
                                                    },
                                                    icon: const Icon(Icons.add_photo_alternate)),
                                              ],
                                            )
                                          )
                                          : Center(
                                            child: IconButton(
                                              onPressed: () async {
                                                ImagePicker imagePicker = ImagePicker();
                                                XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

                                                if(file == null) return;

                                                setState(() {
                                                  _image = File(file.path);
                                                });
                                              },
                                              icon: const Icon(Icons.add_photo_alternate)),
                                      ),
                                    ),
                                  ],
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
                                          Fluttertoast.showToast(
                                              msg: "Successfully Added New Menu",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              fontSize: 20.0,
                                              backgroundColor: Colors.green.withOpacity(0.8),
                                              textColor: Colors.white
                                          );
                                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RestaurantHome(user: widget.user)));
                                        }catch(e){
                                          Fluttertoast.showToast(
                                              msg: e.toString(),
                                              fontSize: 20.0,
                                              backgroundColor: Colors.redAccent.withOpacity(0.8),
                                              textColor: Colors.white
                                          );
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
          ),
        ),
      ),
    );
  }
}
