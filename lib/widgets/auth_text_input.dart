import 'package:flutter/material.dart';

class AuthTextInput extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isPassword;
  final FormFieldSetter<String> onSaved;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;

  const AuthTextInput({
    Key? key,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    required this.onSaved,
    this.onChanged,
    required this.textInputAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
      obscureText: isPassword,
      onSaved: onSaved,
      onChanged: onChanged,
      textInputAction: textInputAction,
    );
  }
}
