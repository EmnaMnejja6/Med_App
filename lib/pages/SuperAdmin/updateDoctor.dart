import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateDoctor extends StatefulWidget {
  @override
  _UpdateDoctorState createState() => _UpdateDoctorState();
}

class _UpdateDoctorState extends State<UpdateDoctor> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          setState(() {
            phoneController.text = documentSnapshot.get('phone');
            addressController.text = documentSnapshot.get('address');
          });
        }
      });
    }
  }

  void _updateDoctor() async {
    await _firestore.collection('users').doc(user!.uid).update({
      'phone': phoneController.text,
      'address': addressController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profil mis à jour !')),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mettre à jour le Profil'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Numéro de téléphone'),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Adresse'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () {
                _updateDoctor();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Color(0xFF084cac),
            ),
            tooltip: 'Modifier',
            onPressed: () {
              _showEditDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Numéro de téléphone'),
              readOnly: true,
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Adresse'),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
}
