import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signUpWithUsernameAndPassword(
      String username, String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user data including the username in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'bio': 'Empty about....',
        'userType': 'user', // Adding userType field with default value 'user'
        // Add more user data if needed
      });
    } catch (e) {
      // print('Error signing up: $e');
      rethrow;
    }
  }

  Future<void> signInWithUsernameAndPassword(
      String username, String password) async {
    try {
      // Retrieve user data from Firestore based on the provided username
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw 'User not found';
      }

      // Get the user's email address from Firestore
      String email = querySnapshot.docs.first['email'];

      // Sign in with email and password using Firebase Authentication
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      // print('Error signing in: $e');
      rethrow;
    }
  }
}
