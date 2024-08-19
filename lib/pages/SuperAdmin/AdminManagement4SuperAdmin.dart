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
      appBar: AppBar(title: const Text("Liste des admins")),
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
                  print('Erreur du StreamBuilder: ${snapshot.error}');
                  return Center(
                      child: Text('Erreur du StreamBuilder: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print('Aucun admin trouvé');
                  return Center(child: Text('Aucun admin trouvé'));
                }

                var admins = snapshot.data!.docs;

                print('Nombre d\'admins: ${admins.length}');

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
                              tooltip: 'Modifier',
                              onPressed: () {
                                // Implémenter la fonctionnalité de modification
                                // Exemple: Navigator.push vers la page de modification
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              tooltip: 'Supprimer',
                              onPressed: () {
                                // Supprimer de l'authentification
                                _deleteAdmin(docId, email, password);
                                // Supprimer le document de Firestore
                                FirebaseFirestore.instance
                                    .collection('admin')
                                    .doc(docId)
                                    .delete()
                                    .then((_) => print(
                                        'Document avec ID $docId supprimé'))
                                    .catchError((error) => print(
                                        'Échec de la suppression du document: $error'));
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(docId)
                                    .delete()
                                    .then((_) => print(
                                    'Document avec ID $docId supprimé'))
                                    .catchError((error) => print(
                                    'Échec de la suppression du document: $error'));
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
      // Supprimer le document de l'admin de la collection 'admin'
      await FirebaseFirestore.instance.collection('admin').doc(docId).delete();

      // Supprimer l'entrée de l'utilisateur de la collection 'users'
      await FirebaseFirestore.instance.collection('users').doc(docId).delete();

      // Supprimer l'utilisateur de l'authentification Firebase
      await _authServices.deleteUser(email, password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin supprimé avec succès')),
      );
    } catch (error) {
      print('Échec de la suppression de l\'admin: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression de l\'admin')),
      );
    }
  }
}
