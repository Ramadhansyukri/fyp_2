import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe_package;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyp_2/services/database.dart';
import 'package:http/http.dart' as http;

import '../../models/user_models.dart';

class TopUpScreen extends StatefulWidget {
  //const TopUpScreen({Key? key}) : super(key: key);
  const TopUpScreen({Key? key,required this.user}) : super(key: key);

  final Users? user;

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final List _amounts = [10, 20, 30, 50, 70, 100];
  TextEditingController amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Topup e-wallet",
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
        body: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Custom amount",
                      prefixText: "RM ",
                    ),
                    keyboardType: TextInputType.number,
                    controller: amountController,
                    validator: (value) {
                      if(value!.isEmpty || !RegExp(r'^\d+$').hasMatch(value)) {
                        return "Incorrect value";
                      } else {
                        if(double.parse(value) < 1) {
                          return "Enter minimum amount of RM1";
                        } else {
                          return null;
                        }
                      }
                    },
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: GridView.builder(
                          itemCount: _amounts.length,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.5
                          ),
                          itemBuilder: (_, int index) {
                            return Card(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      amountController = TextEditingController(text: _amounts[index].toString());
                                    });
                                  },
                                  child: Center(
                                    child: Text(
                                      "RM ${_amounts[index]}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                )
                            );
                          }
                      )
                  ),
                  RawMaterialButton(
                    fillColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    ),
                    onPressed: () async {
                      if(formKey.currentState!.validate()) {
                        Fluttertoast.showToast(msg: "validated");
                        await _pay(context);
                      }
                    },
                    child: const Text(
                      "Pay",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _createPaymentIntent() async {
    var uname = 'sk_test_51NDeeAHKlJGYNRxo6U6Mw922Qke5c3fWlylOL5Rf5vxwRMDLWHKmjAvz23eAIR4pib0tIRqCOx0KmcAywmO8BUoK005GZwwO6Z';
    var pass = '';
    var auth = 'Basic ${base64Encode(utf8.encode('$uname:$pass'))}';

    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': auth,
    };

    var data = 'amount=${int.parse(amountController.text)*100}&currency=myr&payment_method_types[]=fpx';

    var url = Uri.parse('https://api.stripe.com/v1/payment_intents');
    var res = await http.post(url, headers: headers, body: data);

    return json.decode(res.body);
  }

  Future _pay(BuildContext context) async {
    final result = await _createPaymentIntent();
    final clientSecret = await result['client_secret'];

    debugPrint(result.toString());
    try {
      await stripe_package.Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const stripe_package.PaymentMethodParams.fpx(
          paymentMethodData: stripe_package.PaymentMethodDataFpx(
            testOfflineBank: false,
          ),
        ),
      );


      await UserDatabaseService(uid: widget.user!.uid.toString()).updateUserBalance(double.parse(amountController.text))
          .then((value) => {
        Fluttertoast.showToast(msg: "Payment successfully completed"),
      });
    } on Exception catch (e) {
      if (e is stripe_package.StripeException) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error from Stripe: ${e.error.localizedMessage}'),
            ),
          );
        }
      } else {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unforeseen error: $e'),
            ),
          );
        }
      }
    }
  }
}

