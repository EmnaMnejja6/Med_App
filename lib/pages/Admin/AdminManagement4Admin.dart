import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:enis/pages/SuperAdmin&Admin/add_admin.dart';

import '../../user_auth/firebase_implementation/firebase_auth_services.dart';

class ManageAdmin4Admin extends StatefulWidget {
  const ManageAdmin4Admin({Key? key}) : super(key: key);

  @override
  _ManageAdmin4AdminState createState() => _ManageAdmin4AdminState();
}

class _ManageAdmin4AdminState extends State<ManageAdmin4Admin> {
  final FirebaseAuthServices _authServices = FirebaseAuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admins list")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream:
              FirebaseFirestore.instance.collection('admin').snapshots(),
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
                  print('No admins found');
                  return Center(child: Text('No admins found'));
                }

                var admins = snapshot.data!.docs;

                print('Number of admins: ${admins.length}');

                return ListView.builder(
                  itemCount: admins.length,
                  itemBuilder: (context, index) {
                    var admin = admins[index];
                    var docId = admin.id;
                    var nom = admin['nom'];
                    var prenom = admin['prenom'];
                    var email = admin['mail'];
                    var adresse = admin['adresse'];
                    var tel = admin['tel'];
                    print('Admin: $nom $prenom');

                    return Card(
                      child: ListTile(
                        title: Text('$nom $prenom '),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFF084cac),
                              ),
                              tooltip: 'Modify',
                              onPressed: () {
                                _showUpdateDialog(docId, adresse, tel);
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
                  PageRouteBuilder(pageBuilder: (_, __, ___) => AddAdmin()));
            },
            child: Text("Ajouter un Admin"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAdmin(String docId, String email, String password) async {
    try {
      // Delete admin document from 'admin' collection
      await FirebaseFirestore.instance.collection('admin').doc(docId).delete();

      // Delete user entry from 'users' collection
      await FirebaseFirestore.instance.collection('users').doc(docId).delete();

      // Delete user from Firebase Authentication
      await _authServices.deleteUser(email, password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin supprimé avec succès')),
      );
    } catch (error) {
      print('EErreur lors de la suppression de l\'admin: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression de l\'admin')),
      );
    }
  }

  Future<void> _showUpdateDialog(String docId, String adresse, String tel) async {
    TextEditingController adresseController = TextEditingController(text: adresse);
    TextEditingController telController = TextEditingController(text: tel);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mettre à jour Admin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: adresseController,
                decoration: InputDecoration(labelText: 'Adresse'),
              ),
              TextField(
                controller: telController,
                decoration: InputDecoration(labelText: 'Téléphone'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await _updateAdmin(docId, adresseController.text, telController.text);
                Navigator.pop(context);
              },
              child: Text('Mettre à jour'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAdmin(String docId, String adresse, String tel) async {
    try {
      await FirebaseFirestore.instance.collection('admin').doc(docId).update({
        'adresse': adresse,
        'tel': tel,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mise à jour avec succés')),
      );
    } catch (error) {
      print('Failed to update admin: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de mise à jour')),
      );
    }
  }
}
