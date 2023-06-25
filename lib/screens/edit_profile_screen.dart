import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/shared/theme_helper.dart';
import 'package:motion_toast/motion_toast.dart';
import '../models/user_models.dart';
import '../widgets/header_widget.dart';
import 'package:email_validator/email_validator.dart';
import 'package:get/get.dart';


class EditProfile extends StatefulWidget {
  //const UserReg({Key? key}) : super(key: key);

  final Users? user;
  final Function(String, String) updateProfile;

  const EditProfile({Key? key,required this.user,required this.updateProfile}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  final _formKey = GlobalKey<FormState>();

  var email = '';
  var username = '';
  var phoneNo = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData(){
    setState(() {
      email = widget.user!.email;
      username = widget.user!.name;
      phoneNo = widget.user!.phone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
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
                              enabled: false,
                              initialValue: widget.user?.email,
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
                        ),
                        const SizedBox(height: 20.0),
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShadow(),
                          child: TextFormField(
                              initialValue: widget.user?.name,
                              decoration: ThemeHelper().textInputDecoration('Username', 'Enter your username'),
                              onChanged: (val) {
                                setState(() => username = val);
                              }
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShadow(),
                          child: TextFormField(
                              initialValue: widget.user?.phone,
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
                          decoration: ThemeHelper().buttonBoxDecoration(context),
                          child: ElevatedButton(
                            style: ThemeHelper().buttonStyle(),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                              child: Text(
                                "Update".toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()){
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.user?.uid) // Assuming the user ID is stored in the 'id' field
                                      .update({
                                    'username': username,
                                    'phone': phoneNo,
                                  });
                                  if(mounted){
                                    MotionToast.success(
                                      title:  const Text("Updated"),
                                      description:  const Text("profile successfully updated"),
                                      animationDuration: const Duration(seconds: 1),
                                      toastDuration: const Duration(seconds: 2),
                                    ).show(context);
                                  }
                                  widget.updateProfile(username, phoneNo);
                                  Get.back();
                                } catch (error) {
                                  MotionToast.error(
                                    title:  const Text("Error update Profile"),
                                    description:  Text(error.toString()),
                                    animationDuration: const Duration(seconds: 1),
                                    toastDuration: const Duration(seconds: 2),
                                  ).show(context);
                                }
                              }
                            },
                          ),
                        ), //Sign In button
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