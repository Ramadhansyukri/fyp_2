import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/shared/theme_helper.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth.dart';
import '../widgets/header_widget.dart';
import 'package:email_validator/email_validator.dart';


class UserReg extends StatefulWidget {
  //const UserReg({Key? key}) : super(key: key);

  final Function() onClickedSignin;

  const UserReg({Key? key,required this.onClickedSignin,}) : super(key: key);

  @override
  State<UserReg> createState() => _UserRegState();
}

class _UserRegState extends State<UserReg> {

  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  final _usertypelist = ["Customer", "Restaurant", "Rider"];
  String? _usertype = "Customer";

  var email = '';
  var password = '';
  var username = '';
  var phoneNo = '';

  File? _image;
  var imageUrl = "";

  var fullAddress = '';
  var addressLine1 = '';
  var addressLine2 = 'Universiti Teknologi Malaysia';
  var addressLine3 = '81310, Johor Bahru, Johor';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            const SizedBox(
              height: 150,
              child: HeaderWidget(150, false, Icons.person_add_alt_1_rounded),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(25, 50, 25, 10),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    width: 5, color: Colors.white),
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
                                color: Colors.grey.shade300,
                                size: 80.0,
                              ),
                            ),
                          ],
                        ),//person icon
                        const SizedBox(height: 30,),
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShadow(),
                          child: TextFormField(
                            decoration: ThemeHelper().textInputDecoration('Username', 'Enter your username'),
                              onChanged: (val) {
                                setState(() => username = val);
                              }
                          ),
                        ),//username
                        const SizedBox(height: 20.0),
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShadow(),
                          child: TextFormField(
                              decoration: ThemeHelper().textInputDecoration("E-mail address", "Enter your email"),
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if(val!.isEmpty){
                                  return "Email can't be empty";
                                }
                                else if(!EmailValidator.validate(val)){
                                  return "Enter a valid email address";
                                }
                                return null;
                              },
                              onChanged: (val) {
                                setState(() => email = val);
                              }
                          ),
                        ),//email address
                        const SizedBox(height: 20.0),
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShadow(),
                          child: TextFormField(
                            decoration: ThemeHelper().textInputDecoration(
                                "Mobile Number",
                                "Enter your mobile number"),
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if(val!.isEmpty){
                                return "Phone number can't be empty";
                              }
                              else if(!RegExp(r"^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$").hasMatch(val)){
                                return "Enter a valid phone number";
                              }
                              return null;
                            },
                              onChanged: (val) {
                                setState(() => phoneNo = val);
                              }
                          ),
                        ),//mobile number
                        const SizedBox(height: 20.0),
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShadow(),
                          child: TextFormField(
                              obscureText: true,
                              decoration: ThemeHelper().textInputDecoration(
                                  "Password", "Enter your password"),
                              validator: (val) {
                                if ((val!.isNotEmpty) && (val.length <8)) {
                                  return "Password must be at least 8 character";
                                }
                                return null;
                              },
                              onChanged: (val){
                                setState(() => password = val);
                              }
                          ),
                        ),//password
                        const SizedBox(height: 20.0),
                        DropdownButtonFormField(
                          value: _usertype,
                          items: _usertypelist.map(
                                  (e) => DropdownMenuItem(value: e,child: Text(e),)
                          ).toList(),
                          onChanged: (val){
                            setState(() {
                              _usertype = val as String;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down_circle,
                            color: Colors.pink
                          ),
                          dropdownColor: Colors.pink.shade50,
                          decoration: ThemeHelper().textInputDecoration(
                              "User Type",
                              ""),
                        ),//User type
                        if (_usertype == "Restaurant") ...[
                          const SizedBox(height: 30,),
                          const Text(
                            "Restaurant registration",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                          const SizedBox(height: 30,),
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
                          const SizedBox(height: 30,),
                          Container(
                            decoration: ThemeHelper().inputBoxDecorationShadow(),
                            child: TextFormField(
                                decoration: ThemeHelper().textInputDecoration(
                                  'Block, College/Faculty',
                                  'Block, College/Faculty',),
                                validator: (val){
                                  if(val!.isEmpty){
                                    return "Field can't be empty";
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  setState(() => addressLine1 = val);
                                }
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300], // Set the background color to greyish
                              borderRadius: BorderRadius.circular(100.0), // Add border radius for rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5), // Add a shadow for depth
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2), // Offset the shadow
                                ),
                              ],
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Address Line 2",
                                hintText: "Address Line 2",
                                border: InputBorder.none, // Remove the default border
                                contentPadding: EdgeInsets.all(16.0), // Add padding for text content
                              ),
                              enabled: false,
                              initialValue: addressLine2,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300], // Set the background color to greyish
                              borderRadius: BorderRadius.circular(100.0), // Add border radius for rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5), // Add a shadow for depth
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2), // Offset the shadow
                                ),
                              ],
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Address Line 3",
                                hintText: "Address Line 3",
                                border: InputBorder.none, // Remove the default border
                                contentPadding: EdgeInsets.all(16.0), // Add padding for text content
                              ),
                              enabled: false,
                              initialValue: addressLine3,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20.0),
                        Container(
                          decoration: ThemeHelper().buttonBoxDecoration(context),
                          child: ElevatedButton(
                            style: ThemeHelper().buttonStyle(),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                              child: Text(
                                "Register".toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()){

                                if(_usertype == "Restaurant"){
                                  String filename = DateTime.now().millisecondsSinceEpoch.toString();

                                  Reference referenceRoot = FirebaseStorage.instance.ref().child('restimages');
                                  Reference referenceImageToUpload = referenceRoot.child(filename);

                                  await referenceImageToUpload.putFile(_image!);
                                  imageUrl = await referenceImageToUpload.getDownloadURL();
                                }
                                fullAddress = '$addressLine1,$addressLine2,$addressLine3';
                                if (context.mounted){
                                  await _auth.registerWithEmailAndPassword(
                                      email, password, username, phoneNo, _usertype!, context,
                                      imageUrl, fullAddress
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10,20,10,20),
                          child: Text.rich(
                              TextSpan(
                                  children: [
                                    const TextSpan(text: "Already have an account? "),
                                    TextSpan(
                                      text: 'Sign in',
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = widget.onClickedSignin,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                                    ),
                                  ]
                              )
                          ),
                        ),//Sign In button
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


