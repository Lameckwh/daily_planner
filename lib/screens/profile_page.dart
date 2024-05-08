import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eco_tourism/widgets/text_box.dart';
import 'package:eco_tourism/forms/login_page.dart'; // Assuming you have a login screen

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  final usersCollection = FirebaseFirestore.instance.collection('users');
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new $field',
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context)),
          TextButton(
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(newValue))
        ],
      ),
    );
    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(currentUser!.uid).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if currentUser is null, if so, navigate to login screen
    if (currentUser == null) {
      return const LoginPage(); // Navigate to login screen if not logged in
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('Profile'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser!.uid) // Use userId instead of email
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("No data found"),
            );
          }
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          if (userData == null) {
            return const Center(
              child: Text("User data is null"),
            );
          }
          return ListView(
            children: [
              const SizedBox(
                height: 50,
              ),
              const Icon(Icons.person, size: 72),
              const SizedBox(
                height: 10,
              ),
              if (currentUser != null)
                Text(
                  currentUser!.email ?? 'Email not available',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  'My Details',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextBox(
                text: userData['username'],
                sectionName: ('Username'),
                onPressed: () => editField('username'),
              ),
              TextBox(
                text: userData['bio'],
                sectionName: 'About',
                onPressed: () => editField('bio'),
              ),
            ],
          );
        },
      ),
    );
  }
}
