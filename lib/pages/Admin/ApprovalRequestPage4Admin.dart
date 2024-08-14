import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../ManageEmails.dart';
import '../../user_auth/firebase_implementation/firebase_auth_services.dart';
import 'ApprovalRequest.dart';
import 'package:enis/user_auth/presentation/newlogin.dart';
import 'package:get/get.dart';

class CombinedRequestsPage extends StatefulWidget {
  @override
  _CombinedRequestsPageState createState() => _CombinedRequestsPageState();
}

class _CombinedRequestsPageState extends State<CombinedRequestsPage> with SingleTickerProviderStateMixin {
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
        content: Text('User approved successfully'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
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
        content: Text('User rejected successfully'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }


  /*****************PATIENTS**********************/
  Future<void> _rejectDeletePatientRequest(BuildContext context, String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('deletionRequests').doc(requestId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request rejected and deleted')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject and delete request: $error')),
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
        print('No such document!');
        return {};
      }
    } catch (e) {
      print('Error fetching patient credentials: $e');
      return {};
    }
  }

  Future<void> _approveDeletePatientRequest(BuildContext context, String requestId, String targetUid) async {
    try {
      Map<String, String> credentials = await getPatientsCredentials(targetUid);
      String patientNom = credentials['patientNom'] ?? '';
      String patientPrenom = credentials['patientPrenom'] ?? '';

      if (patientNom.isEmpty || patientPrenom.isEmpty) {
        throw Exception('Failed to fetch patientNom or patientPrenom');
      }

      await FirebaseFirestore.instance.collection('deletionRequests').doc(requestId).delete();
      await FirebaseFirestore.instance.collection('patients').doc(targetUid).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient supprimé avec succès')),
      );

    } catch (e) {
      print("error $e");
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
      print('Error fetching deletion requests: $e');
      return [];
    }
  }

  //Build the Patient Deletion Tab
  Widget _buildPatientDeletionRequestsTab(BuildContext context, List<Map<String, dynamic>> requests) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deletion Requests'),
        bottom: TabBar(
          tabs: [
            Tab(text: 'Patient Deletion Requests'),
            Tab(text: 'Image Deletion Requests'),
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchPatientDeletionRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No deletion requests found'));
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
          ),
          // Placeholder for the second tab
          Center(child: Text('Image Deletion Requests')),
        ],
      ),
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
          return Center(child: Text('Error: ${streamSnapshot.error}'));
        }
        if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
          return Center(child: Text('No approval requests found'));
        }

        var requests = streamSnapshot.data!.docs;

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var doc = requests[index];
            var request = ApprovalRequest.fromDocument(doc);

            return Card(
              child: ListTile(
                title: Text('Request to create a new account'),
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


  /*******************************************/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Requests"),
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
          //patients tab
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchPatientDeletionRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No deletion requests found'));
              } else {
                return _buildPatientDeletionRequestsTab(context, snapshot.data!);
              }
            },
          ),
        ],
      ),
    );
  }
}
