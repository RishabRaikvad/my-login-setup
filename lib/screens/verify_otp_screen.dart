import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_login_setup/screens/home_screen.dart';
import 'package:my_login_setup/screens/setup_profile_screen.dart';
import 'package:my_login_setup/services/firebase_auth_service.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String verificationId;
  final String phone;

  const VerifyOtpScreen({
    super.key,
    required this.verificationId,
    required this.phone,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final otpController = TextEditingController();
  final FirebaseAuthService _userService = FirebaseAuthService();

  void verifyOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: otpController.text,
    );

    UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    bool completed = await _userService.isProfileCompleted(userCred.user!.uid);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => completed ? HomeScreen() : SetupProfileScreen(),
        ),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify OTP")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(labelText: "Enter OTP"),
            ),
            ElevatedButton(onPressed: verifyOTP, child: Text("Verify")),
          ],
        ),
      ),
    );
  }
}
