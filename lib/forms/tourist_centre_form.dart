import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import 'add_image_widget.dart';
import 'edit_image_widget.dart';

final Logger logger = Logger();

class TouristCentresForm extends StatefulWidget {
  final String? documentId;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? location;
  final String? price;
  final String? description;
  final DateTime? datePosted;
  final String? imageUrl;

  const TouristCentresForm({
    super.key,
    this.documentId,
    this.name,
    this.email,
    this.phoneNumber,
    this.location,
    this.price,
    this.description,
    this.datePosted,
    this.imageUrl,
  });

  @override
  State<TouristCentresForm> createState() => _TouristCentresFormState();
}

class _TouristCentresFormState extends State<TouristCentresForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isPostSuccess = false;
  bool showAlert = false; // Added to control the visibility of the alert
  String name = '';
  String email = '';
  String phoneNumber = '';
  String location = '';
  String? price = '';
  String description = '';
  DateTime datePosted = DateTime.now();
  File? image;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imagePermanent = await saveImagePermanently(image.path);
      setState(() => this.image = imagePermanent);
    } on PlatformException catch (e) {
      logger.e("Failed to pick image: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // Set the initial values in the form fields when editing
    name = widget.name ?? '';
    email = widget.email ?? '';
    phoneNumber = widget.phoneNumber ?? '';
    location = widget.location ?? '';
    price = widget.price ?? '';
    description = widget.description ?? '';
    datePosted = widget.datePosted ?? DateTime.now();
  }

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final title = basename(imagePath);
    final image = File("${directory.path}/$title");

    return File(imagePath).copy(image.path);
  }

  Future<String?> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      final storage = FirebaseStorage.instance;
      final storageRef = storage.ref().child('tourist_centre_images');

      final originalExtension = imageFile.path.split('.').last;
      final imageName =
          '${DateTime.now().millisecondsSinceEpoch}.$originalExtension';

      final uploadTask = storageRef.child(imageName).putFile(imageFile);

      await uploadTask.whenComplete(() => null);
      return await storageRef.child(imageName).getDownloadURL();
    } catch (e) {
      logger.e("Error uploading image to Firebase Storage");

      return null;
    }
  }

  Future<void> uploadDataToFirebase() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
        isPostSuccess = false;
        showAlert = false; // Reset the showAlert state
      });

      _formKey.currentState?.save();

      final duplicateQuery = await FirebaseFirestore.instance
          .collection('tourist_centres')
          .where('name', isEqualTo: name)
          .where('email', isEqualTo: email)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('location', isEqualTo: location)
          .where('price', isEqualTo: price)
          .where('description', isEqualTo: description)
          .get();

      if (duplicateQuery.docs.isNotEmpty) {
        setState(() {
          isLoading = false;
        });

        logger.d("Duplicate document found. Please enter unique values.");
        return;
      }

      String? imageUrl;

      if (image != null) {
        imageUrl = await uploadImageToFirebaseStorage(image!);
        if (imageUrl == null) {
          setState(() {
            isLoading = false;
          });
          return;
        }
      }

      await FirebaseFirestore.instance.collection('tourist_centres').add({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'location': location,
        'price': price,
        'description': description,
        'datePosted': datePosted,
        'imageUrl': imageUrl,
      });

      _formKey.currentState?.reset();

      setState(() {
        isLoading = false;
        isPostSuccess = true;
        showAlert = true; // Set showAlert to true to display the alert
      });
      logger.i("tourist_centre posted successfully!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create tourist_centre'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    image != null
                        ? EditImageWidget(
                            image: image!,
                            onClicked: (source) => pickImage(source),
                          )
                        : AddImageWidget(
                            image: File('images/image-outline-filled.png'),
                            onClicked: (source) => pickImage(source),
                          ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter tourist centre name',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          name = value ?? '';
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter tourist centre email',
                        ),
                        keyboardType: TextInputType
                            .emailAddress, // Set the keyboard type to email address
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the email';
                          }
                          // Validate email format using RegExp
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          email = value ?? '';
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter tourist centre's phone number",
                        ),
                        keyboardType: TextInputType
                            .phone, // Set the keyboard type to phone number
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the phone number';
                          }
                          // Validate phone number format using RegExp
                          if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          phoneNumber = value ?? '';
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter tourist centre location',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the location';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          location = value ?? '';
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter tourist centre price',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the price';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          price = value ?? '';
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter the description',
                        ),
                        maxLines: null,
                        minLines: 6,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the description';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          description = value ?? '';
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isLoading ? null : uploadDataToFirebase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 165, 0, 1),
                        minimumSize: const Size(
                          200,
                          50,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Post',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Ubuntu",
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showAlert)
            Center(
              child: AlertDialog(
                title: const Text('Success'),
                content: const Text('tourist_centre posted successfully!'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showAlert = false; // Close the alert
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
