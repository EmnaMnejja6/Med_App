import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../../google_drive_service.dart';
import 'image_upload_mobile.dart';
import 'image_upload_web.dart';

class PhotoDialog extends StatefulWidget {
  final String doctorId;
  final String patientId;
  final String position;

  const PhotoDialog({
    required this.doctorId,
    required this.patientId,
    this.position = 'Autre',
    Key? key,
  }) : super(key: key);

  @override
  _PhotoDialogState createState() => _PhotoDialogState();
}

class _PhotoDialogState extends State<PhotoDialog> {
  late GoogleDriveService _googleDriveService;
  bool _isLoading = false; 
  final Map<String, String?> _imagePaths = {
    'Face en position assise': null,
    'Profil en position assise': null,
    'Face en position couchée': null,
    'Profil en position couchée': null,
    'Autre': null,
  };

  @override
  void initState() {
    super.initState();
    _initializeGoogleDriveService();
  }

  Future<void> _initializeGoogleDriveService() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/service_account.json');
      final credentialsJson = await rootBundle.loadString('assets/service_account.json');
      await file.writeAsString(credentialsJson);
      _googleDriveService = GoogleDriveService(credentialsJson);
    } catch (e) {
      print('Erreur d\'initialiser Google Drive service: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur d\'initialiser Google Drive service: $e')),
      );
    }
  }

  Future<void> _uploadImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });

    final String fileName = '${widget.patientId.padLeft(3, '0')}_NA_001.jpg';

    try {
      // Initialize the Google Drive service if it hasn't been initialized yet
      if (_googleDriveService == null) {
        await _initializeGoogleDriveService();
      }

      // Fetch the photoUrl from the patient collection with position 'Autre'
      final DocumentSnapshot patientSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .get();

      String? photoUrl;
      if (patientSnapshot.exists) {
        final Map<String, dynamic>? patientData =
        patientSnapshot.data() as Map<String, dynamic>?;
        photoUrl = patientData?['photos']?[widget.position] as String?;
      }

      // If photoUrl is null or not found, proceed with the upload
      if (photoUrl == null) {
        if (kIsWeb) {
          final uploadWeb = UploadWeb(
            context: context,
            googleDriveService: _googleDriveService,
            imagePaths: _imagePaths,
            isLoading: _isLoading,
            setLoading: (bool loading) => setState(() => _isLoading = loading),
          );
          await uploadWeb.pickAndUploadImage(widget.doctorId, widget.patientId, fileName);
        } else {
          final uploadMobile = UploadMobile(
            context: context,
            googleDriveService: _googleDriveService,
            picker: ImagePicker(),
          );
          await uploadMobile.uploadImageMobile(widget.doctorId, widget.patientId, widget.position, source: source);
        }
      }

      // Update Firestore with the photoUrl and other details
      if (photoUrl != null) {
        _imagePaths[widget.position] = photoUrl;

        final Map<String, dynamic> updateData = {
          'photos': _imagePaths,
        };

        await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientId)
            .update(updateData);
      }
    } catch (e) {
      print('Erreur d\'enregistrer le fichier: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur d\'enregistrer le fichier: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading) ...[
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Ajout en cours ... Veuillez patienter'),
          ] else ...[
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _uploadImage(ImageSource.gallery),
                  icon: Icon(Icons.photo, color: Colors.white),
                  label: Text('Galerie', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _uploadImage(ImageSource.camera),
                  icon: Icon(Icons.photo_camera, color: Colors.white),
                  label: Text('Camera', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF084cac),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
