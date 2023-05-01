import 'package:flutter/material.dart';
import 'package:fyp_2/services/auth.dart';
import 'package:fyp_2/shared/constants.dart';
import 'package:fyp_2/shared/loading.dart';

class UserReg extends StatefulWidget {
  //const UserReg({Key? key}) : super(key: key);

  final Function toggleView;
  UserReg({ required this.toggleView});

  @override
  State<UserReg> createState() => _UserRegState();
}

class _UserRegState extends State<UserReg> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  var email = '';
  var password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.pink[900],
      appBar: AppBar(
        backgroundColor: Colors.pink[600],
        elevation: 0.0,
        title: Text('User Register'),
        actions: <Widget>[
          ElevatedButton.icon(
            icon: Icon(Icons.person),
            label: Text('Sign In'),
            onPressed: () {
              widget.toggleView();
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Email'),
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  onChanged: (val) {
                    setState(() => email = val);
                  }
              ),
              SizedBox(height: 20.0),
              TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Password'),
                  obscureText: true,
                  validator: (val) => val!.length <8 ? 'Password must be at least 8 character' : null,
                  onChanged: (val){
                    setState(() => password = val);
                  }
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                child: Text(
                  'Register',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()){
                    setState(() => loading = true);
                    dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                    if(result == null){
                      setState(() => error = 'Please supply valid info');
                      setState(() {
                        error = 'Please supply valid info';
                        loading = false;
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 12.0),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              )
            ],
          ),
        ),
      ),
    );
  }
}
