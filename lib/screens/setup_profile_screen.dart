import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_login_setup/screens/home_screen.dart';
import 'package:my_login_setup/services/firebase_auth_service.dart';

import '../models/user_model.dart';
import '../services/image_upload_service.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String gender = "Male";
  DateTime? dob;
  File? profileImage;
  final ImageUploadService _imageService = ImageUploadService();

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
      });
    }
  }

  Future<void> pickDOB() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dob = pickedDate;

        final today = DateTime.now();
        int age = today.year - pickedDate.year;
        if (today.month < pickedDate.month ||
            (today.month == pickedDate.month && today.day < pickedDate.day)) {
          age--;
        }
        ageController.text = age.toString();
      });
    }
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate() || dob == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please complete all fields")));
      return;
    }
    setState(() => loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final imageUrl = await _imageService.uploadProfileImage(
        image: profileImage!,
        uid: user.uid,
      );

      UserModel newUser = UserModel(
        uid: user.uid,
        name: nameController.text.trim(),
        phone: user.phoneNumber ?? "",
        email: emailController.text.trim(),
        gender: gender,
        age: int.parse(ageController.text),
        dob: dob!,
        isProfileCompleted: true,
        createdAt: DateTime.now(),
        profileImageUrl: imageUrl,
      );

      await FirebaseAuthService().createUser(newUser);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to save profile")));
        debugPrint("Failed :- ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Setup Profile")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : null,
                  child: profileImage == null
                      ? Icon(Icons.camera_alt, size: 30)
                      : null,
                ),
              ),
              SizedBox(height: 16),

              // Name
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (v) => v == null || v.isEmpty ? "Enter name" : null,
              ),

              SizedBox(height: 12),

              // Email
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || !v.contains("@") ? "Enter valid email" : null,
              ),

              SizedBox(height: 12),

              // DOB Picker
              GestureDetector(
                onTap: pickDOB,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "Date of Birth",
                      hintText: dob == null
                          ? "Select DOB"
                          : "${dob!.day}/${dob!.month}/${dob!.year}",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (_) =>
                        dob == null ? "Select date of birth" : null,
                  ),
                ),
              ),

              SizedBox(height: 12),

              // Age (auto-filled)
              TextFormField(
                controller: ageController,
                decoration: InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
                readOnly: true,
              ),

              SizedBox(height: 12),

              // Gender
              DropdownButtonFormField<String>(
                initialValue: gender,
                decoration: InputDecoration(labelText: "Gender"),
                items: ["Male", "Female", "Other"]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => gender = v!),
              ),

              SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : saveProfile,
                  child: loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Save Profile"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
