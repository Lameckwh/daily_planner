import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import '../forms/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Fetch hotel data from Firestore
    checkUserLoginStatus();

    fetchHotels();
  }

  // Function to fetch hotel data from Firestore
  void fetchHotels() async {
    final QuerySnapshot hotelSnapshot =
        await FirebaseFirestore.instance.collection('hotels').get();
    final List<Map<String, dynamic>> fetchedHotels = hotelSnapshot.docs
        .map((doc) => {
              'name': doc['name'],
              'imageUrl': doc['imageUrl'],
            })
        .toList();

    setState(() {});
  }

  void checkUserLoginStatus() {
    // final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    setState(() {
      _isLoggedIn = user != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
        elevation: 1,
        // titleSpacing: 1,
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          _isLoggedIn
              ? IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    // Perform logout action
                    FirebaseAuth.instance.signOut().then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logout Successful'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      setState(() {
                        _isLoggedIn = false;
                      });
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logout Failed. Please try again.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () async {
                    // Navigate to login page
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                    // Check if login was successful
                    if (result == true) {
                      setState(() {
                        _isLoggedIn = true;
                      });
                    }
                  },
                ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: Colors.grey,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text("Welcome to Daily Planner",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Top Tasks",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w700),
                        ),
                        TextButton(
                          onPressed: () async {},
                          child: const Text("See All"),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
