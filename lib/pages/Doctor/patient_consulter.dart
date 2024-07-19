import 'package:enis/pages/Doctor/PhotoPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // For formatting dates

import 'ViewPhotos.dart';

class PatientPage extends StatefulWidget {
  final String doctorId;
  final String patientId;

  const PatientPage({required this.doctorId, required this.patientId, Key? key}) : super(key: key);

  @override
  _PatientPageState createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _adresseController;
  late TextEditingController _telController;
  String _nom = '';
  String _prenom = '';
  String _dateDeNaissance = '';
  int _age = 0;

  @override
  void initState() {
    super.initState();
    _adresseController = TextEditingController();
    _telController = TextEditingController();
    _fetchPatientInfo();
  }

  Future<void> _fetchPatientInfo() async {
    try {
      DocumentSnapshot patientDoc = await _firestore
          .collection('patients')
          .doc(widget.patientId)
          .get();

      if (patientDoc.exists) {
        Map<String, dynamic>? patientData = patientDoc.data() as Map<String, dynamic>?;
        if (patientData != null) {
          DateTime birthDate = (patientData['DateNais'] as Timestamp).toDate();
          int age = DateTime.now().year - birthDate.year;
          if (DateTime.now().month < birthDate.month || (DateTime.now().month == birthDate.month && DateTime.now().day < birthDate.day)) {
            age--;
          }

          setState(() {
            _nom = patientData['Nom'] ?? '';
            _prenom = patientData['Prenom'] ?? '';
            _dateDeNaissance = DateFormat('yyyy-MM-dd').format(birthDate);  // Format the date as desired
            _age = age;
            _adresseController.text = patientData['Adresse'] ?? '';
            _telController.text = patientData['tel'] ?? '';
          });
          print('Patient info fetched: $_nom $_prenom $_dateDeNaissance, Age: $_age');
        } else {
          print('No patient data found');
        }
      } else {
        print('Patient document does not exist');
      }
    } catch (e) {
      print('Error fetching patient info: $e');
    }
  }

  Future<void> _updatePatientInfo() async {
    try {
      await _firestore.collection('patients').doc(widget.patientId).update({
        'adresse': _adresseController.text,
        'tel': _telController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Information updated')));
    } catch (e) {
      print('Error updating patient info: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update information')));
    }
  }

  @override
  void dispose() {
    _adresseController.dispose();
    _telController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Information'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: $_nom', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Prénom: $_prenom', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Date de Naissance: $_dateDeNaissance', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Âge: $_age', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            TextField(
              controller: _adresseController,
              decoration: InputDecoration(labelText: 'Adresse'),
            ),
            TextField(
              controller: _telController,
              decoration: InputDecoration(labelText: 'Numéro de Téléphone'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePatientInfo,
              child: Text('Mettre à jour'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            Text('Ajouter une Photo:'),
            SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoPage(
                            doctorId: widget.doctorId,
                            patientId: widget.patientId,
                          ),
                        ),
                      );
                    },
                    child: Text('Ajouter une photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewPhotosPage(
                            doctorId: widget.doctorId,
                            patientId: widget.patientId,
                          ),
                        ),
                      );
                    },
                    child: Text('Voir Photos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
