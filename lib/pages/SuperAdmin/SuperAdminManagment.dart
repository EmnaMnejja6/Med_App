import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:enis/pages/SuperAdmin/add_super_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../user_auth/firebase_implementation/firebase_auth_services.dart';


class ManageSuperAdmin extends StatefulWidget {
  const ManageSuperAdmin({super.key});

  @override
  State<ManageSuperAdmin> createState() => _ManageSuperAdminState();
}

class _ManageSuperAdminState extends State<ManageSuperAdmin> {
  final FirebaseAuthServices _authServices = FirebaseAuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SuperAdmins list")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('superadmin')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('Erreur: ${snapshot.error}');
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print('Aucun superadmin trouvé');
                  return Center(child: Text('Aucun superadmin trouvé'));
                }

                var superadmins = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: superadmins.length,
                  itemBuilder: (context, index) {
                    var superadmin = superadmins[index];
                    var docId = superadmin.id;
                    var nom = superadmin['nom'];
                    var prenom = superadmin['prenom'];
                    var email = superadmin['mail'];
                    var password = superadmin['password'];
                    print('Super Admin: $nom $prenom');
                    return Card(
                      child: ListTile(
                        title: Text('$nom $prenom'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              tooltip: 'Supprimer',
                              onPressed: () {
                                _createApprovalRequest(docId);
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
                MaterialPageRoute(builder: (context) => AddSuperAdmin()),
              );
            },
            child: Text("Ajouter un Super Admin"),
          ),
        ],
      ),
    );
  }

  Future<void> _createApprovalRequest(String targetUid) async {
    try {
      String currentUid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('deletionRequests').add({
        'requesterUid': currentUid,
        'targetUid': targetUid,
        'status': 'pending', // initial status
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demande envoyé pour l\'approuver')),
      );
    } catch (error) {
      print('Echec de creer la demande : $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Echec d\'envoyer la demande ')),
      );
    }
  }
}
