import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String role, String nom, String prenom) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      String uid = credential.user!.uid;

      // Add user data to the 'users' collection
      await _firestore.collection('users').doc(uid).set({
        "uid": uid,
        "email": email,
        "role": role,
      });

      // Add additional data to the specific role collection
      if (role == 'admin') {
        await _firestore.collection('admin').doc(uid).set({
          "nom": nom,
          "prenom": prenom,
          "password": password,
          "mail": email,
          "adresse": "",
          "tel":""
        });
      } else if (role == 'super_admin') {
        await _firestore.collection('superadmin').doc(uid).set({
          "nom": nom,
          "prenom": prenom,
          "password": password,
          "mail": email,
          "adresse": "",
          "tel":""
        });
      } else if (role == 'doctor') {
        await _firestore.collection('doctor').doc(uid).set({
          "nom": nom,
          "prenom": prenom,
          "password": password,
          "mail": email,
          "adresse": "",
          "tel":""
        });
      }

      return credential.user;
    } catch (e) {
      print("An error occurred: $e");
      return null;
    }
  }


  Future<Map<String, dynamic>?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Fetch user role from Firestore
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(credential.user!.uid).get();
      if (userDoc.exists) {
        String role = userDoc['role'];
        return {'user': credential.user, 'role': role};
      } else {
        print("No user data found!");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      // Throw specific FirebaseAuthException for handling in UI
      throw e;
    } catch (e) {
      print("An error occurred: $e");
      return null;
    }
  }

  Future<void> deleteUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      String uid = userCredential.user!.uid;

      // Delete user from Firebase Authentication
      await userCredential.user!.delete();
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: $e");
      rethrow;
    } catch (e) {
      print("An error occurred: $e");
      rethrow;
    }
  }
}
