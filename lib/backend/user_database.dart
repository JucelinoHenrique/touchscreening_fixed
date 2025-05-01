import 'package:cloud_firestore/cloud_firestore.dart';

class UserDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserData(String uid, String name) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
    });
  }
}
