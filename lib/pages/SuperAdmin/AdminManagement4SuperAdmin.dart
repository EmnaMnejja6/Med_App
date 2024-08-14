import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:enis/pages/SuperAdmin&Admin/add_admin.dart';

import '../../user_auth/firebase_implementation/firebase_auth_services.dart';

class ManageAdmin4SuperAdmin extends StatefulWidget {
  const ManageAdmin4SuperAdmin({Key? key}) : super(key: key);

  @override
  _ManageAdmin4SuperAdminState createState() => _ManageAdmin4SuperAdminState();
}

class _ManageAdmin4SuperAdminState extends State<ManageAdmin4SuperAdmin> {
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
                    var password = admin['password'];
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
                                color: Colors.blue,
                              ),
                              tooltip: 'Modify',
                              onPressed: () {
                                // Implement edit functionality
                                // Example: Navigator.push to edit page
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              tooltip: 'Delete',
                              onPressed: () {
                                //Delete from auth
                                _deleteAdmin(docId, email, password);
                                // Delete document from Firestore
                                FirebaseFirestore.instance
                                    .collection('admin')
                                    .doc(docId)
                                    .delete()
                                    .then((_) => print(
                                        'Document with ID $docId deleted'))
                                    .catchError((error) => print(
                                        'Failed to delete document: $error'));
                                FirebaseFirestore.instance
                                    .collection('users')
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
      print('Failed to delete admin: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression de l\'admin')),
      );
    }
  }
}
