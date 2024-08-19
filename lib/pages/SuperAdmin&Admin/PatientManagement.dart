import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_patient.dart';

class ManagePatients extends StatefulWidget {
  @override
  _ManagePatientsState createState() => _ManagePatientsState();
}

class _ManagePatientsState extends State<ManagePatients> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des Patients")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('patients').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('StreamBuilder Erreur: ${snapshot.error}');
                  return Center(
                      child: Text('StreamBuilder Erreur: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print('Pas de patient');
                  return Center(child: Text('Pas de patient'));
                }

                var patients = snapshot.data!.docs;

                print('Nombre de Patients: ${patients.length}');

                return ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    var patient = patients[index];
                    var docId = patient.id;
                    var data = patient.data() as Map<String, dynamic>;

                    var nom = data['patientNom'] ?? 'N/A';
                    var prenom = data['patientPrenom'] ?? 'N/A';

                    print('Patient: $nom $prenom');

                    return Card(
                      child: ListTile(
                        title: Text('$nom $prenom'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFF084cac),
                              ),
                              tooltip: 'Modifier',
                              onPressed: () {
                                _showEditDialog(
                                  context,
                                  docId,
                                  data['adresse'],
                                  data['tel'],
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              tooltip: 'Supprimer',
                              onPressed: () {
                                _deletePatient(docId);
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.transfer_within_a_station,
                                color: Colors.green,
                              ),
                              tooltip: 'Transfèrer',
                              onPressed: () {
                                _showTransferDialog(context, docId);
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
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => AddPatientPage(),
                ),
              );
            },
            child: Text("Ajouter un Patient"),
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
          title: Text('Mettre à jour le Profil'),
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
                _updatePatient(docId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updatePatient(String docId) async {
    try {
      await _firestore.collection('patients').doc(docId).update({
        'adresse': addressController.text,
        'tel': phoneController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil mis à jour')),
      );
    } catch (error) {
      print('Echec de mettre à jour les informations du patient: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Echec de mettre à jour les informations du patient')),
      );
    }
  }

  void _deletePatient(String docId) async {
    try {
      await _firestore.collection('patients').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient supprimé avec succès')),
      );
    } catch (e) {
      print('Echec de supprimer le patient: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Echec de supprimer le patient')),
      );
    }
  }

  void _showTransferDialog(BuildContext context, String patientId) {
    String? selectedDoctorId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Transférer Patient'),
          content: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('doctor').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Erreur: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('Pas de docteur joignable');
              }

              var doctors = snapshot.data!.docs;

              return DropdownButton<String>(
                hint: Text('Sélectionner un Docteur'),
                value: selectedDoctorId,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDoctorId = newValue;
                  });
                },
                items: doctors.map<DropdownMenuItem<String>>((DocumentSnapshot document) {
                  var data = document.data() as Map<String, dynamic>;
                  var doctorName = '${data['nom']} ${data['prenom']}';
                  return DropdownMenuItem<String>(
                    value: document.id,
                    child: Text(doctorName),
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Transférer'),
              onPressed: () {
                if (selectedDoctorId != null) {
                  _transferPatient(patientId, selectedDoctorId!);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Séléctionnez un docteur')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _transferPatient(String patientId, String newDoctorId) async {
    try {
      await _firestore.collection('patients').doc(patientId).update({
        'doctorId': newDoctorId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient transferé avec succés')),
      );
    } catch (error) {
      print('Failed to transfer patient: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de transfert')),
      );
    }
  }
}
