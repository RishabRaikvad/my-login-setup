import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_login_setup/screens/home_screen.dart';
import 'package:my_login_setup/screens/login_screen.dart';
import 'package:my_login_setup/screens/setup_profile_screen.dart';

import '../services/firebase_auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuthService _userService = FirebaseAuthService();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), checkAuth);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "My App",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void checkAuth() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      bool completed = await _userService.isProfileCompleted(user.uid);

     if(mounted){
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(
           builder: (_) => completed ? HomeScreen() : SetupProfileScreen(),
         ),
       );
     }
    }
  }
}
