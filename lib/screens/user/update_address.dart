import 'package:flutter/material.dart';
import 'package:fyp_2/services/database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:motion_toast/motion_toast.dart';

import '../../models/user_models.dart';
import '../../shared/theme_helper.dart';

class AddressScreen extends StatefulWidget {
  //const AddressScreen({Key? key}) : super(key: key);
  final Users? user;
  final Function(String) updateAddress;

  const AddressScreen({Key? key,required this.user, required this.updateAddress}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  LatLng _pinpointPosition = const LatLng(1.560012, 103.637973);
  final _formKey = GlobalKey<FormState>();
  var fullAddress = '';
  var addressLine1 = '';
  var addressLine2 = "Universiti Teknologi Malaysia";
  var addressLine3 = "81310, Johor Bahru, Johor";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update Address",
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              Container(
                decoration: ThemeHelper().inputBoxDecorationShadow(),
                child: TextFormField(
                  controller: _addressController,
                  decoration: ThemeHelper().textInputDecoration(
                    'Block, College/Faculty',
                    'Block, College/Faculty',
                  ),
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Field can't be empty";
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() => addressLine1 = val);
                  },
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
              const SizedBox(height: 16.0),
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _pinpointPosition,
                    zoom: 16.0,
                  ),
                  onCameraMove: (CameraPosition position) {
                    setState(() {
                      _pinpointPosition = position.target;
                    });
                  },
                  markers: <Marker>{
                    Marker(
                      markerId: const MarkerId('pinpoint'),
                      position: _pinpointPosition,
                    ),
                  },
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                decoration: ThemeHelper().buttonBoxDecoration(context),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        // Determine the background color based on the button's state
                        return Colors.transparent;
                      },
                    ),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                    child: Text('Set Address'.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
                  ),
                  onPressed: () async{
                    final List<Placemark> placemarks = await placemarkFromCoordinates(
                      _pinpointPosition.latitude,
                      _pinpointPosition.longitude,
                    );

                    if (placemarks.isNotEmpty) {
                      final Placemark placemark = placemarks.first;
                      setState(() {
                        addressLine1 = placemark.name ?? '';
                      });
                      _addressController.text = addressLine1;
                    }
                  },
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                decoration: ThemeHelper().buttonBoxDecoration(context),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        // Determine the background color based on the button's state
                        return Colors.transparent;
                      },
                    ),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                    child: Text('Save Address'.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
                  ),
                  onPressed: () async{
                    if (_formKey.currentState!.validate()){
                      fullAddress = '$addressLine1,$addressLine2,$addressLine3';
                      try{
                        await UserDatabaseService(uid: widget.user!.uid.toString()).updateAddress(fullAddress, widget.user!.usertype);
                        if (context.mounted){
                          MotionToast.success(
                            title:  const Text("Address updated"),
                            description:  const Text("Successfully save address"),
                            animationDuration: const Duration(seconds: 1),
                            toastDuration: const Duration(seconds: 2),
                          ).show(context);
                        }
                        widget.updateAddress(fullAddress);
                      }catch(e){
                        MotionToast.error(
                          title:  const Text("Error updating address"),
                          description:  Text(e.toString()),
                          animationDuration: const Duration(seconds: 1),
                          toastDuration: const Duration(seconds: 2),
                        ).show(context);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}