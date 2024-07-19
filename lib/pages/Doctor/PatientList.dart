import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enis/pages/Doctor/add_patient.dart';
import 'package:enis/pages/Doctor/patient_consulter.dart';

class PatientListPage extends StatefulWidget {
  final String doctorId;

  const PatientListPage({required this.doctorId, Key? key}) : super(key: key);

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes patients"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('patients').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucun patient trouvé'));
                }

                var patients = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    var patient = patients[index];
                    var patientId = patient.id;
                    var avatar = patient['avatar'];
                    var nom = patient['Nom'];
                    var prenom = patient['Prenom'];

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: ClipOval(
                            child: Image.asset('assets/images/$avatar.jpg', fit: BoxFit.cover, width: 50, height: 50),
                          ),
                        ),
                        title: Text('$nom $prenom'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                           backgroundColor:  Colors.blue,
                          ),
                          child: Text(
                            "Consulter",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientPage(
                                  doctorId: widget.doctorId,
                                  patientId: patientId,
                                ),
                              ),
                            );
                          },
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
                MaterialPageRoute(
                  builder: (context) => AddPatientPage(),
                ),
              );
            },
            child: Text("Ajouter un patient"),
          ),
        ],
      ),
    );
  }
}
