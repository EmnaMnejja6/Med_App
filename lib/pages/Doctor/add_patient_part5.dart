import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import '../../google_drive_service.dart';
import 'PatientList.dart';
import 'image_upload_mobile.dart';
import 'image_upload_web.dart';
//import 'image_upload_web.dart';

class PhotoUploadPage extends StatefulWidget {
  final String doctorId;
  final String patientId;
  final String patientNom;
  final String patientPrenom;
  final String patientAddress;
  final DateTime? patientBirthDate;
  final String patientWeight;
  final String patientHeight;
  final String? asaScore;
  final String? surgicalAct;
  final String? inductionType;
  final String? intubationAttempts;
  final String? alternativeTechnique;
  final String? cormackLehaneGrade;

  const PhotoUploadPage({
    required this.doctorId,
    required this.patientId,
    required this.patientNom,
    required this.patientPrenom,
    required this.patientAddress,
    required this.patientBirthDate,
    required this.patientWeight,
    required this.patientHeight,
    this.asaScore,
    this.surgicalAct,
    this.inductionType,
    this.intubationAttempts,
    this.alternativeTechnique,
    this.cormackLehaneGrade,
    Key? key,
  }) : super(key: key);

  @override
  _PhotoUploadPageState createState() => _PhotoUploadPageState();
}

class _PhotoUploadPageState extends State<PhotoUploadPage> {
  File? _pickedImage;
  Uint8List? webImage;

  late GoogleDriveService _googleDriveService;
  bool _isLoading = false;
  final Map<String, String?> _imagePaths = {
    'Face en position assise': null,
    'Profil en position assise': null,
    'Face en position couchée': null,
    'Profil en position couchée': null,
    'Autre': null
  };

  @override
  void initState() {
    super.initState();
    _initializeGoogleDriveService();
  }

  Future<void> _initializeGoogleDriveService() async {
    try {
      if (kIsWeb) {
        final credentialsJson = await rootBundle.loadString(
            'assets/service_account.json');
        _googleDriveService = GoogleDriveService(credentialsJson);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/service_account.json');
        final credentialsJson = await rootBundle.loadString(
            'assets/service_account.json');
        await file.writeAsString(credentialsJson);
        _googleDriveService = GoogleDriveService(credentialsJson);
      }
    } catch (e) {
      print('Error initializing Google Drive service: $e');
    }
  }

  Future<void> _uploadImage(String position, ImageSource source) async {
    setState(() {
      _isLoading = true;
    });

    final String fileName = '${widget.patientId.padLeft(3, '0')}_${_getPhotoCode(position)}_001.jpg';

    try {
      if (kIsWeb) {
        final uploadWeb = UploadWeb(context: context,googleDriveService: _googleDriveService,  imagePaths: _imagePaths, isLoading: _isLoading, setLoading: (bool loading) => setState(() => _isLoading = loading),);
        //UploadWeb
        await uploadWeb.pickAndUploadImage(widget.doctorId, widget.patientId, fileName);
      } else {
        final uploadMobile = UploadMobile(context: context, googleDriveService: _googleDriveService, picker: ImagePicker(),
        );

        await uploadMobile.uploadImageMobile(widget.doctorId, widget.patientId, position,source: source);
      }
    } catch (e) {
      print('Error uploading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  String _getPhotoCode(String position) {
    switch (position) {
      case 'Face en position assise':
        return 'FA';
      case 'Profil en position assise':
        return 'PA';
      case 'Face en position couchée':
        return 'FC';
      case 'Profil en position couchée':
        return 'PC';
      default:
        return 'NA';
    }
  }


  Future<void> _showImageSourceDialog(String position) async {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text('Ajouter image $position'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo_library, size: 30),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _uploadImage(position, ImageSource.gallery);
                        },
                      ),
                      Text('Galerie', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.camera_alt, size: 30),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _uploadImage(position, ImageSource.camera);
                        },
                      ),
                      Text('Camera', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
    }

  Future<void> _submitAllInformation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photos updated successfully!')),
      );
    } catch (e) {
      print('Error updating photos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating photos')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });

      // Navigate to PatientListPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PatientListPage(doctorId: widget.doctorId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Photos de l'enfant"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading) ...[
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 20),
              Text('Ajout en cours ... Veuillez patienter'),
            ] else
              ...[
                ..._imagePaths.keys.map((position) =>
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          position,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _showImageSourceDialog(position),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Ajouter",
                                style: TextStyle(color: Colors.blue),
                              ),
                              SizedBox(width: 5),
                              Icon(Icons.upload, color: Colors.blue),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    )).toList(),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.green),
                    ),
                    onPressed: _submitAllInformation,
                    child: Text(
                      "Envoyer",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

