import 'dart:io';
import 'package:enis/pages/Super%20Admin/super_admin_panel.dart';
import 'package:enis/pages/home_page%20.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'google_drive_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() async {
  print("starting now");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //await addFirstSuperAdmin();

  runApp(MyApp());
}

Future<void> addFirstSuperAdmin() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String email = "superadmin@gmail.com";
  String password = "123";
  String role = "super_admin";

  try {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await _firestore.collection('users').doc(credential.user!.uid).set({
      "email": email,
      "role": role,
    });
    print("Super Admin created successfully!");
  } catch (e) {
    print("An error occurred: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NewHomePage(),
    );
  }
}

