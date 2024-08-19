import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../ManageEmails.dart';
import '../../user_auth/firebase_implementation/firebase_auth_services.dart';
import 'ApprovalRequest.dart';
import 'package:enis/user_auth/presentation/newlogin.dart';
import 'package:get/get.dart';

class CombinedRequestsPage4SuperAdmin extends StatefulWidget {
  @override
  _CombinedRequestsPage4SuperAdminState createState() => _CombinedRequestsPage4SuperAdminState();
}

class _CombinedRequestsPage4SuperAdminState extends State<CombinedRequestsPage4SuperAdmin> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuthServices _authServices = FirebaseAuthServices();
  final ManageEmails _emailService = ManageEmails();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Approve New Account
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
        content: Text('Erreur: $e'),
      ));
    }
  }

  // Reject New Account
  Future<void> _rejectUser(BuildContext context,
      ApprovalRequest request) async {
    try {
      await _emailService.sendRejectionEmail(request.email);
      await FirebaseFirestore.instance.collection('pending')
          .doc(request.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Utilisateur refusé avec succès'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur: $e'),
      ));
    }
  }

  // Get Current User UID
  String? getCurrentUserUid() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }


  // Delete User Account
  Future<void> _deleteUserAccount(String email, String password) async {
    try {
      User? user = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password).then((
          userCredential) => userCredential.user);

      if (user != null) {
        await user.delete();
        Get.offAll(() => LoginPage());
      }
    } catch (error) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(content: Text('Echec de supprimer l\'utilisateur: $error')));
    }
  }

  // Reject SA deletion request
  Future<void> _rejectDeleteRequest(BuildContext context, String requestId) async {
    try {
      // Delete the request document from the 'deletionRequests' collection
      await FirebaseFirestore.instance.collection('deletionRequests').doc(requestId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demande refusée et supprimée')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Echec de supprimer la demande: $error')),
      );
    }
  }


  Future<Map<String, String>> getSuperAdminCredentials(String uid) async {
    try {
      // Reference to the 'superadmin' collection
      CollectionReference superAdminCollection = FirebaseFirestore.instance
          .collection('superadmin');

      // Get the document snapshot for the provided UID
      DocumentSnapshot documentSnapshot = await superAdminCollection.doc(uid)
          .get();

      if (documentSnapshot.exists) {
        // Extract email and password from the document data
        String email = documentSnapshot.get('mail');
        String password = documentSnapshot.get('password');

        return {'email': email, 'password': password};
      } else {
        print('Document introuvable!');
        return {};
      }
    } catch (e) {
      print('Erreur fetching super admin credentials: $e');
      return {};
    }
  }

  //Approve SA deletion request
  Future<void> _approveDeleteRequest(BuildContext context, String requestId, String targetUid) async {
    try {
      // Fetch email and password from the superadmin collection
      Map<String, String> credentials = await getSuperAdminCredentials(targetUid);
      String email = credentials['email'] ?? '';
      String password = credentials['password'] ?? '';

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Echec de trouver email ou password');
      }

      // Delete the request document from the 'deletionRequests' collection
      await FirebaseFirestore.instance.collection('deletionRequests').doc(requestId).delete();

      // Delete the superadmin document from Firestore
      await FirebaseFirestore.instance.collection('superadmin').doc(targetUid).delete();
      print('Superadmin supprimé de Firestore avec succès: $targetUid');

      // Call the method to delete the user from Firebase Authentication
      await _deleteUserAccount(email, password);

      // Display a message in the UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Superadmin supprimé avec succès')),
      );

      // If the current user is the one being deleted, sign out and navigate to login
      if (targetUid == getCurrentUserUid()) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      print('Echec d\'approuver la demande: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Echec d\'approuver la demande: ${e.toString()}')),
      );
    }
  }



  Widget buildDeletionRequestsTab(BuildContext context, List<Map<String, dynamic>> requests) {
    if (requests.isEmpty) {
      return Center(child: Text('Pas de demande de suppression'));
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        var request = requests[index];
        var requestId = request['requestId'];
        var patientId = request['targetUid'];
        var patientNom = request['patientNom'];
        var patientPrenom = request['patientPrenom'];
        return Card(
          child: ListTile(
            title: Text('Patient Name: $patientNom'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () => _approveDeleteRequest(context, requestId, patientId),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => _rejectDeleteRequest(context, requestId),
                ),
              ],
            ),
          ),
        );
      },
    );
  }





/*****************PATIENTS**********************/
  Future<void> _rejectDeletePatientRequest(BuildContext context, String requestId) async {
    try {
      print('Essai de supprimer la demande avec ID: $requestId');
      await FirebaseFirestore.instance.collection('patientDeletionRequests').doc(requestId).delete();
      print('Demande supprimé avec succès avec ID: $requestId');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demande refusé et supprimé')),
      );
    } catch (error) {
      print('Echec de supprimer la demande avec ID $requestId: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Echec de supprimer la demande: $error')),
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
        print('Document introuvable!');
        return {};
      }
    } catch (e) {
      print('Erreur fetching patient credentials: $e');
      return {};
    }
  }

  Future<void> _approveDeletePatientRequest(BuildContext context, String requestId, String targetUid) async {
    try {
      print('Essai d\'approuver la demande de suppression avec ID: $requestId pour patient ID: $targetUid');
      Map<String, String> credentials = await getPatientsCredentials(targetUid);
      String patientNom = credentials['patientNom'] ?? '';
      String patientPrenom = credentials['patientPrenom'] ?? '';

      if (patientNom.isEmpty || patientPrenom.isEmpty) {
        throw Exception('Echec  fetch patientNom or patientPrenom');
      }

      await FirebaseFirestore.instance.collection('patientDeletionRequests').doc(requestId).delete();
      print('Demande supprimé avec succès avec ID: $requestId');
      await FirebaseFirestore.instance.collection('patients').doc(targetUid).delete();
      print('Patient supprimé avec succès avec ID: $targetUid');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient supprimé avec succès')),
      );
    } catch (e) {
      print('Erreur d\'approuver la demande de suppression avec ID $requestId pour patient ID $targetUid: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Echec de supprimer le patient: $e')),
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
      print('Erreur fetching demande de suppression: $e');
      return [];
    }
  }

  //Build the Patient Deletion Tab
  Widget _buildPatientDeletionRequestsTab(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchPatientDeletionRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucune demande de suppression'));
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
                  title: Text('Patient Name: $patientNom $patientPrenom'),
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

    // Build the New Accounts Requests Tab
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
            return Center(child: Text('Erreur: ${streamSnapshot.error}'));
          }
          if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucune demande approuvée '));
          }

          var requests = streamSnapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var doc = requests[index];
              var request = ApprovalRequest.fromDocument(doc);

              return Card(
                child: ListTile(
                  title: Text('Demande de créer nouveau compte'),
                  subtitle: Text('Name: ${request.firstName} ${request
                      .lastName}\nEmail: ${request.email}\nRole: ${request
                      .role}'),
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

    // Build SA Deletion Requests Tab
    Widget _buildDeletionRequestsTab(BuildContext context) {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('deletionRequests')
            .where('targetUid', isEqualTo: getCurrentUserUid())
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucune demande de suppression'));
          }

          var requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              var requestId = request.id;
              var requesterUid = request['requesterUid'];
              var targetUid = request['targetUid'];


              return Card(
                child: ListTile(
                  title: Text('Demande de suppression SuperAdmin: $targetUid'),
                  subtitle: Text('Demandé par: $requesterUid'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          _approveDeleteRequest(context, requestId, targetUid);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          _rejectDeleteRequest(context, requestId);
                        },
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
              Tab(text: "Suppression du compte SA"),
              Tab(text: "Suppression des patients"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildApprovalRequestsTab(context),
            _buildDeletionRequestsTab(context),
            _buildPatientDeletionRequestsTab(context),
          ],
        ),
      );
    }

}
