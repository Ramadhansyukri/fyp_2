import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe_package;
import 'package:http/http.dart' as http;
import 'package:bcrypt/bcrypt.dart' as encrypt;
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';

import '../../models/user_models.dart';
import '../../services/database.dart';

class RestCashOut extends StatefulWidget {
  const RestCashOut({Key? key, required this.user}) : super(key: key);

  final Users? user;

  @override
  State<RestCashOut> createState() => _RestCashOutState();
}

class _RestCashOutState extends State<RestCashOut> {
  TextEditingController amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cash Out",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Custom amount",
                    prefixText: "RM ",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  validator: (value) {
                    const pattern = r'^\d+(\.\d{1,2})?$';
                    final regExp = RegExp(pattern);
                    if (value!.isEmpty || !regExp.hasMatch(value)) {
                      return "Incorrect value";
                    } else {
                      if (double.parse(value) < 1) {
                        return "Enter a minimum amount of RM1";
                      } else {
                        return null;
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      _showPinScreen(
                        context,
                        opaque: false,
                        cancelButton: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          semanticsLabel: 'Cancel',
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("Cash Out"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPinScreen(
      BuildContext context, {
        bool opaque = false,
        CircleUIConfig? circleUIConfig,
        KeyboardUIConfig? keyboardUIConfig,
        required Widget cancelButton,
        List<String>? digits,
      }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: opaque,
        pageBuilder: (context, animation, secondaryAnimation) => PasscodeScreen(
          title: const Text(
            'Enter App Passcode',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),
          circleUIConfig: circleUIConfig,
          keyboardUIConfig: keyboardUIConfig,
          passwordEnteredCallback: _onPasscodeEntered,
          cancelButton: cancelButton,
          deleteButton: const Text(
            'Delete',
            style: TextStyle(fontSize: 16, color: Colors.white),
            semanticsLabel: 'Delete',
          ),
          shouldTriggerVerification: _verificationNotifier.stream,
          backgroundColor: Colors.black.withOpacity(0.8),
          cancelCallback: _onPasscodeCancelled,
          digits: digits,
          passwordDigits: 6,
        ),
      ),
    );
  }

  void _onPasscodeCancelled() {
    Navigator.maybePop(context);
  }

  void _onPasscodeEntered(String enteredPasscode) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.user!.uid);
    final userData = await userDoc.get();
    final storedPin = userData.get('PIN') as String;
    final bool isPinValid = encrypt.BCrypt.checkpw(enteredPasscode, storedPin);
    _verificationNotifier.add(isPinValid);
    if (isPinValid) {
        double userBalance = await UserDatabaseService(uid: widget.user!.uid.toString()).getUserBalance();
        if (userBalance >= double.parse(amountController.text)) {
          if(mounted){
            cashOut(context);
          }
        }else{
          if(mounted){
            if (context.mounted) {
              CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                title: 'Oops...',
                text: 'Insufficient Balance',
                loopAnimation: false,
              );
            }
          }
        }
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent() async {
    var uname = 'sk_test_51NDeeAHKlJGYNRxo6U6Mw922Qke5c3fWlylOL5Rf5vxwRMDLWHKmjAvz23eAIR4pib0tIRqCOx0KmcAywmO8BUoK005GZwwO6Z';
    var pass = '';
    var auth = 'Basic ${base64Encode(utf8.encode('$uname:$pass'))}';

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': auth,
    };

    final data = 'amount=${int.parse(amountController.text) * 100}&currency=myr&payment_method_types[]=fpx';

    final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
    final res = await http.post(url, headers: headers, body: data);

    return json.decode(res.body);
  }

  Future<void> cashOut(BuildContext context) async {
    final result = await createPaymentIntent();
    final clientSecret = await result['client_secret'];

    try {
      await stripe_package.Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const stripe_package.PaymentMethodParams.fpx(
          paymentMethodData: stripe_package.PaymentMethodDataFpx(
            testOfflineBank: false,
          ),
        ),
      );

        await UserDatabaseService(uid: widget.user!.uid.toString()).deductUserBalance(double.parse(amountController.text)).then((value) {
          CoolAlert.show(
            context: context,
            type: CoolAlertType.success,
            text: 'Transaction completed successfully!',
            autoCloseDuration: const Duration(seconds: 2),
          );
        });

    } catch (e) {
      if (mounted) {
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: 'Transaction Failed',
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    }
  }
}
