 import 'dart:io';
import 'package:enis/pages/SuperAdmin/super_admin_panel.dart';
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
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';



void main() async {
  print("starting now");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await addFirstSuperAdmin();

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
      routes: {
        '/home': (context) => SuperAdminPanel(),
        // other routes
      },
      title: 'MedApp',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: HomePage(),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'ManageEmails.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EmailTestPage(),
    );
  }
}

class EmailTestPage extends StatelessWidget {
  final ManageEmails _emailService = ManageEmails();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _emailService.sendApprovalEmail('emna.mnejja1808@gmail.com');
              },
              child: Text('Send Approval Email'),
            ),
            ElevatedButton(
              onPressed: () {
                _emailService.sendRejectionEmail('emna.mnejja1808@gmail.com');
              },
              child: Text('Send Rejection Email'),
            ),
          ],
        ),
      ),
    );
  }
}
*/


/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? _pickedImage;
  Uint8List? webImage;

  Future<void> _uploadImage() async {
    final ImagePicker _picker = ImagePicker();
    if (!kIsWeb) {
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          _pickedImage = selected;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } else {
        print('Error: No image selected.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No image selected.')),
        );
      }
    } else if (kIsWeb) {
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          _pickedImage = File('a');
          webImage = f;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } else {
        print('Error: No image selected on web.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No image selected on web.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Image Picker Example"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _uploadImage,
                child: const Text("Upload Photo"),
              ),
              const SizedBox(height: 20),
              if (_pickedImage != null)
                kIsWeb
                    ? Image.memory(webImage!, height: 200, width: 200, fit: BoxFit.cover)
                    : Image.file(_pickedImage!, height: 200, width: 200, fit: BoxFit.cover)
              else
                const Text('No image selected.'),
            ],
          ),
        ),
      ),
    );
  }
}
*/