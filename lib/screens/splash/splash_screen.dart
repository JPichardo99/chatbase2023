import 'dart:developer';
import 'package:chatbase/api/apis.dart';
import 'package:chatbase/constants.dart';
import 'package:chatbase/screens/Welcome/welcome_screen.dart';
import 'package:chatbase/screens/home_screen.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:chatbase/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ));
    if (APIs.auth.currentUser != null) {
      log('\nUser: ${APIs.auth.currentUser}');
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      });
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          //const SizedBox(height: 250),
          const SizedBox(height: 100),
          Image.asset(
            'assets/images/favorite-heart-like.png',
            height: 312,
            width: 312,
          ),
          const SizedBox(height: 20),
          const Text(
            'Bienvenido de nuevo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sigue disfrutando de la experiencia de chatbase',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 150),
          const SizedBox(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
            ),
            height: 70.0,
            width: 70.0,
          ),
        ],
      ),
    ));
  }
}
