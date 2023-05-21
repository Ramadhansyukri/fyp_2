import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fyp_2/shared/theme_helper.dart';

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
                                if (!(val!.isEmpty) && (val.length <8)) {
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
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(child: CircularProgressIndicator())
                              );
                              if (_formKey.currentState!.validate()){
                                await _auth.registerWithEmailAndPassword(email, password, username, phoneNo, _usertype!, context);
                              }
                            },
                          ),
                        ),//Register button
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


