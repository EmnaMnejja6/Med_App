import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../google_drive_service.dart';
import 'PhotoPage.dart';
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
  GoogleDriveService? _googleDriveService;
  String _nom = '';
  String _prenom = '';
  String _adresse = '';
  String _dateDeNaissance = '';
  int _age = 0;
  String _patientWeight = '';
  String _patientHeight = '';
  String? _asaScore;
  String? _surgicalAct;
  String? _inductionType;
  String? _intubationAttempts;
  String? _alternativeTechnique;
  String? _cormackLehaneGrade;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    try {
      final credentialsJson = await rootBundle.loadString('assets/service_account.json');
      setState(() {
        _googleDriveService = GoogleDriveService(credentialsJson); // Initialize GoogleDriveService
      });
      _fetchPatientInfo();
    } catch (e) {
      print('Error loading credentials: $e');
    }
  }

  Future<void> _fetchPatientInfo() async {
    try {
      DocumentSnapshot patientDoc = await _firestore.collection('patients').doc(widget.patientId).get();

      if (patientDoc.exists) {
        Map<String, dynamic>? patientData = patientDoc.data() as Map<String, dynamic>?;
        if (patientData != null) {
          DateTime birthDate = (patientData['DateNaissance'] as Timestamp).toDate();
          int age = DateTime.now().year - birthDate.year;
          if (DateTime.now().month < birthDate.month || (DateTime.now().month == birthDate.month && DateTime.now().day < birthDate.day)) {
            age--;
          }

          setState(() {
            _nom = patientData['patientNom'] ?? '';
            _prenom = patientData['patientPrenom'] ?? '';
            _dateDeNaissance = DateFormat('yyyy-MM-dd').format(birthDate);
            _age = age;
            _adresse = patientData['patientAdress'] ?? '';
            _patientWeight = patientData['Poids'] ?? '';
            _patientHeight = patientData['Taille'] ?? '';
            _asaScore = patientData['ASAScore'];
            _surgicalAct = patientData['ActeChirurgical'];
            _inductionType = patientData['InductionType'];
            _intubationAttempts = patientData['IntubationAttempts'];
            _alternativeTechnique = patientData['AlternativeTechnique'];
            _cormackLehaneGrade = patientData['CormackLehaneGrade'];
          });
          print('Patient info fetched: $_nom $_prenom $_dateDeNaissance, Adresse: $_adresse');
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


  Future<void> _deletePatient(String targetUid) async {
    try {
      // Get the current user's UID
      String requesterUid = await getCurrentUserUid();

      // Create a new deletion request
      await FirebaseFirestore.instance.collection('patientDeletionRequests').add({
        'requesterUid': requesterUid,
        'targetUid': targetUid,
        'status': 'pending',
      });

      print('Deletion request added successfully');

    } catch (e) {
      // Handle any errors that occur
      print('Failed to add deletion request: $e');
    }
  }

  Future<String> getCurrentUserUid() async {
    return widget.doctorId;
  }

  Future<void> _showPhotoDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter une Photo'),
        content: PhotoDialog(
          doctorId: widget.doctorId,
          patientId: widget.patientId,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fiche Patient'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info Section
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPatientInfoRow('Nom', _nom),
                      _buildPatientInfoRow('Prénom', _prenom),
                      _buildPatientInfoRow('Date de Naissance', _dateDeNaissance),
                      _buildPatientInfoRow('Âge', '$_age ans'),
                      _buildPatientInfoRow('Adresse', _adresse),
                      _buildPatientInfoRow('Poids', _patientWeight),
                      _buildPatientInfoRow('Taille', _patientHeight),
                      _buildPatientInfoRow('Score ASA', _asaScore ?? 'Non renseigné'),
                      _buildPatientInfoRow('Acte Chirurgical', _surgicalAct ?? 'Non renseigné'),
                      _buildPatientInfoRow('Type d\'induction', _inductionType ?? 'Non renseigné'),
                      _buildPatientInfoRow('Tentatives d\'intubation', _intubationAttempts ?? 'Non renseigné'),
                      _buildPatientInfoRow('Technique alternative', _alternativeTechnique ?? 'Non renseigné'),
                      _buildPatientInfoRow('Grade de Cormack-Lehane', _cormackLehaneGrade ?? 'Non renseigné'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Actions Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed:  _showPhotoDialog,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_a_photo, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Ajouter une photo', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_googleDriveService != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewPhotosPage(
                              doctorId: widget.doctorId,
                              patientId: widget.patientId,
                              googleDriveService: _googleDriveService!,
                            ),
                          ),
                        );
                      } else {
                        print('GoogleDriveService is not initialized');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Drive Service not available')));
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_library, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Voir Photos', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: (){ _deletePatient(widget.patientId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Une demande de suppression a été envoyée')),
                  );},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Supprimer le patient', style: TextStyle(color: Colors.white)),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
