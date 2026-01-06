import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class FirebaseAuthService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isProfileCompleted(String uid) async {
    final doc = await _firestore.collection("users").doc(uid).get();
    if (!doc.exists) return false;
    return doc.data()?['isProfileCompleted'] ?? false;
  }

  Future<void> createUser(UserModel user) async {
    await _firestore.collection("users").doc(user.uid).set(user.toMap());
  }
}