import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:enis/pages/Super%20Admin/updateDoctor.dart';
import 'package:enis/pages/SuperAdmin&Admin/add_doctor.dart';
import 'package:enis/user_auth/firebase_implementation/firebase_auth_services.dart';

class ManageDoctors extends StatefulWidget {
  const ManageDoctors({super.key});

  @override
  State<ManageDoctors> createState() => _ManageDoctorsState();
}

class _ManageDoctorsState extends State<ManageDoctors> {
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthServices _authServices = FirebaseAuthServices();
  User? user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctors list")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('doctor').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('StreamBuilder Error: ${snapshot.error}');
                  return Center(
                      child: Text('StreamBuilder Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print('No doctors found');
                  return Center(child: Text('No doctors found'));
                }

                var doctors = snapshot.data!.docs;

                print('Number of doctors: ${doctors.length}');

                return ListView.builder(
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    var doctor = doctors[index];
                    var docId = doctor.id;
                    var nom = doctor['nom'];
                    var prenom = doctor['prenom'];
                    var specialite = doctor['specialite'];
                    var email = doctor['mail'];
                    var password = doctor['password'];

                    print('doctor: $nom $prenom');

                    return Card(
                      child: ListTile(
                        title: Text('$nom $prenom \n $specialite '),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              tooltip: 'Modify',
                              onPressed: () {
                                _showEditDialog(context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              tooltip: 'Delete',
                              onPressed: () {
                                //delete mel auth
                                _deleteDoctor(docId, email, password);
                                //delete document mel firestore
                                FirebaseFirestore.instance
                                    .collection('doctor')
                                    .doc(docId)
                                    .delete()
                                    .then((_) => print(
                                        'Document with ID $docId deleted'))
                                    .catchError((error) => print(
                                        'Failed to delete document: $error'));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  PageRouteBuilder(pageBuilder: (_, __, ___) => AddDoctor()));
            },
            child: Text("Ajouter un Docteur"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
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
              child: Text('Save'),
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

  void _updateDoctor() async {
    await _firestore.collection('users').doc(user!.uid).update({
      'phone': phoneController.text,
      'address': addressController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated')),
    );
  }

  Future<void> _deleteDoctor(
      String docId, String email, String password) async {
    try {
      // Delete doctor document from 'doctor' collection
      await FirebaseFirestore.instance.collection('doctor').doc(docId).delete();

      // Delete user entry from 'users' collection
      await FirebaseFirestore.instance.collection('users').doc(docId).delete();

      // Delete user from Firebase Authentication
      await _authServices.deleteUser(email, password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Docteur supprimé avec succès')),
      );
    } catch (error) {
      print('Failed to delete doctor: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du docteur')),
      );
    }
  }
}
