import 'package:flutter/material.dart';
import 'package:password_strength/password_strength.dart';

class UserAuthScreen extends StatefulWidget {
  static const routeName = '/user-auth-screen';

  @override
  _UserAuthScreenState createState() => _UserAuthScreenState();
}

class _UserAuthScreenState extends State<UserAuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _username;
  String? _email;
  String? _password;

  bool _isLoginForm = true;

  void _submit() {
    final form = _formKey.currentState;
    if (form == null) return;

    if (form.validate()) {
      form.save();
      if (_isLoginForm) {
        // Perform login here
        print('Logging in with $_username and $_password');
      } else {
        // Perform sign up here
        print('Signing up with $_username, $_email and $_password');
      }
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required.';
    } else if (value.length < 6) {
      return 'Username must be at least 6 characters.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    } else if (!value.contains('@')) {
      return 'Email must be valid.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    } else if (estimatePasswordStrength(value) < 0.3) {
      return 'Password is too weak. Please choose a stronger password.';
    }
    return null;
  }

  Widget _buildUsernameField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Username'),
      validator: _validateUsername,
      onSaved: (value) => _username = value,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Email'),
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
      onSaved: (value) => _email = value,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Password'),
      obscureText: true,
      validator: _validatePassword,
      onSaved: (value) => _password = value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginForm ? 'Login' : 'Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _isLoginForm ? SizedBox() : _buildUsernameField(),
              _buildEmailField(),
              _buildPasswordField(),
              SizedBox(height: 32.0),
              ElevatedButton(
                child: Text(_isLoginForm ? 'Login' : 'Create account'),
                onPressed: _submit,
              ),
              TextButton(
                child: Text(_isLoginForm ? 'Create an account' : 'Have an account? Log in'),
                onPressed: () {
                  setState(() {
                    _isLoginForm = !_isLoginForm;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
