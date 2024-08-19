import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../ManageEmails.dart';
import '../../user_auth/firebase_implementation/firebase_auth_services.dart';
import 'ApprovalRequest.dart';
import 'package:enis/user_auth/presentation/newlogin.dart';
import 'package:get/get.dart';

class CombinedRequestsPage4Admin extends StatefulWidget {
  @override
  _CombinedRequestsPage4AdminState createState() => _CombinedRequestsPage4AdminState();
}

class _CombinedRequestsPage4AdminState extends State<CombinedRequestsPage4Admin> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuthServices _authServices = FirebaseAuthServices();
  final ManageEmails _emailService = ManageEmails();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Approuver un nouveau compte
  Future<void> _approveUser(BuildContext context,
      ApprovalRequest request) async {
    try {
      await _authServices.signUpWithEmailAndPassword(
        request.email,
        request.password,
        request.role,
        request.lastName,
        request.firstName,
      );

      await _emailService.sendApprovalEmail(request.email);
      await FirebaseFirestore.instance.collection('pending')
          .doc(request.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Utilisateur approuvé avec succès'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : $e'),
      ));
    }
  }
  Future<void> _rejectUser(BuildContext context,
      ApprovalRequest request) async {
    try {
      await _emailService.sendRejectionEmail(request.email);
      await FirebaseFirestore.instance.collection('pending')
          .doc(request.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Utilisateur refusé avec succès '),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : $e'),
      ));
    }
  }


  /*****************PATIENTS**********************/
  Future<void> _rejectDeletePatientRequest(BuildContext context, String requestId) async {
    try {
      print('Tentative de rejet et suppression de la demande avec l\'ID : $requestId');
      await FirebaseFirestore.instance.collection('patientDeletionRequests').doc(requestId).delete();
      print('Demande avec l\'ID $requestId supprimée avec succès');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demande rejetée et supprimée')),
      );
    } catch (error) {
      print('Erreur lors du rejet et suppression de la demande avec l\'ID $requestId : $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec du rejet et suppression de la demande : $error')),
      );
    }
  }

  Future<Map<String, String>> getPatientsCredentials(String uid) async {
    try {
      CollectionReference patientsCollection = FirebaseFirestore.instance.collection('patients');
      DocumentSnapshot documentSnapshot = await patientsCollection.doc(uid).get();

      if (documentSnapshot.exists) {
        String patientNom = documentSnapshot.get('patientNom');
        String patientPrenom = documentSnapshot.get('patientPrenom');
        return {'patientNom': patientNom, 'patientPrenom': patientPrenom};
      } else {
        print('Document introuvable !');
        return {};
      }
    } catch (e) {
      print('Erreur lors de la récupération des informations du patient : $e');
      return {};
    }
  }

  Future<void> _approveDeletePatientRequest(BuildContext context, String requestId, String targetUid) async {
    try {
      print('Tentative d\'approbation de la demande de suppression avec l\'ID : $requestId pour le patient avec l\'ID : $targetUid');
      Map<String, String> credentials = await getPatientsCredentials(targetUid);
      String patientNom = credentials['patientNom'] ?? '';
      String patientPrenom = credentials['patientPrenom'] ?? '';

      if (patientNom.isEmpty || patientPrenom.isEmpty) {
        throw Exception('Impossible de trouver le nom ou prénom du patient');
      }

      await FirebaseFirestore.instance.collection('patientDeletionRequests').doc(requestId).delete();
      print('Demande avec l\'ID $requestId supprimée avec succès');
      await FirebaseFirestore.instance.collection('patients').doc(targetUid).delete();
      print('Patient avec l\'ID $targetUid supprimé avec succès');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient supprimé avec succès')),
      );
    } catch (e) {
      print('Erreur lors de l\'approbation et suppression du patient avec l\'ID $targetUid : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de l\'approbation et suppression du patient : $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchPatientDeletionRequests() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('patientDeletionRequests')
          .where('status', isEqualTo: 'pending')
          .get();

      List<Map<String, dynamic>> requests = [];
      for (var doc in snapshot.docs) {
        String requestId = doc.id;
        String targetUid = doc['targetUid'];
        Map<String, String> credentials = await getPatientsCredentials(targetUid);
        String patientNom = credentials['patientNom'] ?? '';
        String patientPrenom = credentials['patientPrenom'] ?? '';
        requests.add({
          'requestId': requestId,
          'targetUid': targetUid,
          'patientNom': patientNom,
          'patientPrenom': patientPrenom
        });
      }
      return requests;
    } catch (e) {
      print('Erreur lors de la récupération des demandes de suppression : $e');
      return [];
    }
  }

  // Construire l'onglet des demandes de suppression de patients
  Widget _buildPatientDeletionRequestsTab(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchPatientDeletionRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucune demande de suppression trouvée'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var request = snapshot.data![index];
              var requestId = request['requestId'];
              var patientId = request['targetUid'];
              var patientNom = request['patientNom'];
              var patientPrenom = request['patientPrenom'];
              return Card(
                child: ListTile(
                  title: Text('Nom du patient : $patientNom $patientPrenom'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approveDeletePatientRequest(context, requestId, patientId),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectDeletePatientRequest(context, requestId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  // Construire l'onglet des demandes de nouveaux comptes
  Widget _buildApprovalRequestsTab(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pending')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, streamSnapshot) {
        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (streamSnapshot.hasError) {
          return Center(child: Text('Erreur : ${streamSnapshot.error}'));
        }
        if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
          return Center(child: Text('Aucune demande d\'approbation trouvée'));
        }

        var requests = streamSnapshot.data!.docs;

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var doc = requests[index];
            var request = ApprovalRequest.fromDocument(doc);

            return Card(
              child: ListTile(
                title: Text('Demande de création d\'un nouveau compte'),
                subtitle: Text('Nom : ${request.firstName} ${request.lastName}\nEmail : ${request.email}\nRôle : ${request.role}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () => _approveUser(context, request),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => _rejectUser(context, request),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  /*******************************************/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demandes"),
        bottom: TabBar(

          controller: _tabController,
          tabs: [
            Tab(text: "Nouveaux Comptes"),
            Tab(text: "Suppression des patients"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApprovalRequestsTab(context),
          _buildPatientDeletionRequestsTab(context),
        ],
      ),
    );
  }
}
