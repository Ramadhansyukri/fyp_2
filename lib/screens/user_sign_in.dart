import 'package:flutter/material.dart';
import 'package:fyp_2/services/auth.dart';

class UserSignIn extends StatefulWidget {
  //const UserSignIn({Key? key}) : super(key: key);

  final Function toggleView;
  UserSignIn({ required this.toggleView});

  @override
  State<UserSignIn> createState() => _UserSignInState();
}

class _UserSignInState extends State<UserSignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  var email = '';
  var password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[900],
      appBar: AppBar(
        backgroundColor: Colors.pink[600],
        elevation: 0.0,
        title: Text('User Sign In'),
        actions: <Widget>[
          ElevatedButton.icon(
            icon: Icon(Icons.person),
            label: Text('Register'),
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
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  onChanged: (val) {
                    setState(() => email = val);
                  }
              ),
              SizedBox(height: 20.0),
              TextFormField(
                  obscureText: true,
                  validator: (val) => val!.length <8 ? 'Password must be at least 8 character' : null,
                  onChanged: (val){
                    setState(() => password = val);
                  }
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                child: Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()){
                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                    if(result == null){
                      setState(() => error = 'Please Enter a Valid Credential');
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
