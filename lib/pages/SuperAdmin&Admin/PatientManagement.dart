import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_patient.dart';

class ManagePatients extends StatefulWidget {
  @override
  _ManagePatientsState createState() => _ManagePatientsState();
}

class _ManagePatientsState extends State<ManagePatients> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des Patients")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream:
              FirebaseFirestore.instance.collection('patients').snapshots(),
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
                  print('No Patients found');
                  return Center(child: Text('No Patient found'));
                }

                var patients = snapshot.data!.docs;

                print('Number of Patients: ${patients.length}');

                return ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    var patient = patients[index];
                    var docId = patient.id;
                    var nom = patient['Nom'];
                    var prenom = patient['Prenom'];
                    print('Patient: $nom $prenom');

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
                  PageRouteBuilder(pageBuilder: (_, __, ___) => AddPatientPage()));
            },
            child: Text("Ajouter un Patient"),
          ),
        ],
      ),
    );
  }
}
