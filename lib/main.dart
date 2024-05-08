import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import the generated file
import 'firebase_options.dart';

import 'screens/navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Logger.level = Level.info;

  final prefs = await SharedPreferences.getInstance();
  final firstTime = prefs.getBool('firstTime') ?? true;

  if (firstTime) {
    runApp(const MyApp(showWelcomePage: true));
    await prefs.setBool('firstTime', false);
  } else {
    runApp(const MyApp(showWelcomePage: false));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.showWelcomePage});

  final bool showWelcomePage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ECO Tourism',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: 'Ubuntu',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(1, 142, 1, 1),
        ).copyWith(background: const Color.fromRGBO(238, 238, 238, 1)),
      ),
      home: showWelcomePage
          ? const WelcomePage(title: 'Eco Tourism')
          : const NavBar(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "images/bg_image.jpg"), // Change the path to your image asset
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25), // Adjust opacity as needed
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Malawi, The Warm Heart of Africa",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Ubuntu',
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'This app will guide you to reach your destination and enjoy the scenery view of different parts of Malawi. Starting from the experience Malawian cultural dances hotels and cultural visits etc.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontFamily: 'Ubuntu',
                        ),
                      ),
                      Text(
                        '',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(255, 165, 0, 1),
                          fontFamily: 'Ubuntu',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 0,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NavBar()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(255, 165, 0, 1),
                    minimumSize: const Size(
                      320,
                      50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Ubuntu",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
