import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../forms/booking_form.dart';
import '../forms/login_page.dart';

class DestinationDetailPage extends StatelessWidget {
  final String name;
  final String email;
  final String phoneNumber;
  final String location;
  final String price;
  final String description;
  final DateTime datePosted;
  final String imageUrl;

  const DestinationDetailPage({
    super.key,
    required this.name,
    required this.location,
    required this.price,
    required this.description,
    required this.datePosted,
    required this.imageUrl,
    required this.email,
    required this.phoneNumber,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Sliver app bar with center image
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height / 3,
                flexibleSpace: FlexibleSpaceBar(
                    background: Image.network(
                  imageUrl, // Replace this with your actual image URL
                  fit: BoxFit.cover,
                )),
                leading: IconButton(
                  // Custom back button
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white), // Set color to white
                  onPressed: () {
                    Navigator.pop(context); // Navigate back when pressed
                  },
                ),
              ),
              // Sliver list with details
              SliverList(
                delegate: SliverChildListDelegate([
                  // Top circle with center details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Center name
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Location
                        Text(
                          'Location: $location',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email: $email',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Phone Number: $phoneNumber',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),

                        // Price description
                        Text(
                          ' Min: MK$price/night', // Assuming the price is in dollars
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 8),
                        // Price description
                        Text(
                          description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        // Gallery
                        const Text(
                          'Gallery',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Gallery images
                        GridView.count(
                          crossAxisCount: 3,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            for (int i = 0; i < 6; i++)
                              Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: const DecorationImage(
                                    image:
                                        AssetImage('images/protea_hotel.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
          // Floating button

          Positioned(
            bottom: 16,
            left: MediaQuery.of(context).size.width / 2 - 150,
            child: SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () async {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Retrieve user's email
                    String userEmail = user.email ?? '';

                    // Retrieve username from Firestore
                    String userName = await _getUserName(user.uid);
                    await Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingForm(
                          placeName: name,
                          userName: userName,
                          userEmail: userEmail,
                        ),
                      ),
                    );
                  } else {
                    // If user is not authenticated, navigate to login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(255, 165, 0, 1),
                  minimumSize: const Size(320, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Reserve Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Ubuntu",
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getUserName(String userId) async {
    try {
      // Retrieve user document from Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Retrieve username from document
      String userName = userSnapshot['username'];

      return userName;
    } catch (e) {
      return '';
    }
  }
}
