import 'package:cloud_firestore/cloud_firestore.dart';

class UserDatabase {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<bool> addUser(User user) async {
    try {
      await usersCollection.doc(user.username).set({
        'username': user.username,
        'name': user.name,
        'password': user.password,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<User?> verifyUser(String username, String password) async {
    try {
      final doc = await usersCollection.doc(username).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['password'] == password) {
          return User(data['name'], data['password'], data['username']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> checkUserExists(String username) async {
    try {
      final doc = await usersCollection.doc(username).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}

class User {
  String username;
  String name;
  String password;

  User(this.name, this.password, this.username);
}

UserDatabase userDb = UserDatabase();
