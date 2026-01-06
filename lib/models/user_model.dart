import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String gender;
  final int age;
  final DateTime dob;
  final bool isProfileCompleted;
  final DateTime createdAt;
  final String profileImageUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    required this.age,
    required this.dob,
    required this.isProfileCompleted,
    required this.createdAt,
    required this.profileImageUrl
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      gender: map['gender'],
      age: map['age'],
      dob: DateTime.parse(map['dob']),
      isProfileCompleted: map['isProfileCompleted'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      profileImageUrl:  map['profileImageUrl'] ?? ""
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'age': age,
      'dob': dob.toIso8601String(),
      'isProfileCompleted': isProfileCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'profileImageUrl': profileImageUrl
    };
  }
}
