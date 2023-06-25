import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/menu_models.dart';
import '../../models/user_models.dart';

class EditMenu extends StatefulWidget {
  final Users? user;
  final String menuID;

  const EditMenu({Key? key, required this.user, required this.menuID})
      : super(key: key);

  @override
  _EditMenuState createState() => _EditMenuState();
}

class _EditMenuState extends State<EditMenu>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  File? _image;
  var imageUrl = "";
  var foodName = "";
  var foodDesc = "";
  double amount = 0.00;

  late AnimationController _animationController;
  late Animation<Offset> _headerOffsetAnimation;

  late Menu _menu;

  TextEditingController _foodNameController = TextEditingController();
  TextEditingController _foodDescController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _headerOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();

    fetchMenuDetails();
  }

  void fetchMenuDetails() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('restaurant')
        .doc(widget.user!.uid)
        .collection('menu')
        .doc(widget.menuID)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      try {
        setState(() {
          _menu = Menu.fromJson(data);
          imageUrl = _menu.imageUrl;
          foodName = _menu.name;
          foodDesc = _menu.desc;
          amount = _menu.price;

          // Set initial values in text controllers
          _foodNameController.text = foodName;
          _foodDescController.text = foodDesc;
          _amountController.text = amount.toStringAsFixed(2);
        });
      } catch (e) {
        // Handle any errors that occurred during JSON parsing or state updating
      }
    } else {
      // Handle case when the document doesn't exist
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('menu_images')
        .child('${DateTime.now()}.jpg');

    await ref.putFile(_image!);

    final imageUrl = await ref.getDownloadURL();

    setState(() {
      this.imageUrl = imageUrl;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _foodNameController.dispose();
    _foodDescController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuID,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        child: SlideTransition(
          position: _headerOffsetAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Details',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      await _pickImage(ImageSource.gallery);
                      await _uploadImage();
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                        image: DecorationImage(
                          image: _image != null
                              ? FileImage(_image!)
                              : (imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : const AssetImage('assets/images/empty_image.png')
                          as ImageProvider),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: _image == null && imageUrl.isEmpty ? const Icon(
                        Icons.add_a_photo,
                        color: Colors.grey,
                        size: 40,
                      ) : null,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _foodNameController,
                        decoration: const InputDecoration(
                          labelText: 'Food Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a food name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _foodDescController,
                        decoration: const InputDecoration(
                          labelText: 'Food Description',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a food description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                        ),
                        keyboardType:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()){
                            final updatedMenu = Menu(
                              menuID: widget.menuID,
                              imageUrl: imageUrl,
                              name: _foodNameController.text,
                              desc: _foodDescController.text,
                              price: double.parse(_amountController.text),
                            );

                            await FirebaseFirestore.instance
                                .collection('restaurant')
                                .doc(widget.user!.uid)
                                .collection('menu')
                                .doc(widget.menuID)
                                .update(updatedMenu.toJson());

                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
