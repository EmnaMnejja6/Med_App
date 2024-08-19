import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  @override
  void dispose() {
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des docteurs")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('doctor').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Pas de docteur'));
                }

                var doctors = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    var doctor = doctors[index];
                    var docId = doctor.id;
                    var data = doctor.data() as Map<String, dynamic>?;

                    var nom = data?['nom'] ?? 'N/A';
                    var prenom = data?['prenom'] ?? 'N/A';
                    var email = data?['mail'] ?? 'N/A';
                    var password = data?['password'] ?? 'N/A';
                    var adresse = data?['adresse'] ?? 'N/A';
                    var tel = data?['tel'] ?? 'N/A';

                    return Card(
                      child: ListTile(
                        title: Text('$nom $prenom'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF084cac)),
                              tooltip: 'Modifier',
                              onPressed: () {
                                _showEditDialog(context, docId, adresse, tel);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Supprimer',
                              onPressed: () {
                                _deleteDoctor(docId, email, password);
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddDoctor()),
              );
            },
            child: Text("Ajouter un Docteur"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String docId, String? adresse, String? tel) {
    addressController.text = adresse ?? '';
    phoneController.text = tel ?? '';

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
                  decoration: InputDecoration(labelText: 'Téléphone'),
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
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () {
                _updateDoctor(docId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateDoctor(String docId) async {
    try {
      await _firestore.collection('doctor').doc(docId).update({
        'adresse': addressController.text,
        'tel': phoneController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil mis à jour')),
      );
    } catch (error) {
      print('Echec de mettre à jour les informations du docteur: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Echec de mettre à jour les informations du docteur')),
      );
    }
  }

  Future<void> _deleteDoctor(String docId, String email, String password) async {
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
      print('Failed to delete Doctor: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du docteur')),
      );
    }
  }
}
