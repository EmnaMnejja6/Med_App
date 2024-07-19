import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:enis/google_drive_service.dart';

class PhotoPage extends StatefulWidget {
  final String doctorId;
  final String patientId;

  const PhotoPage({required this.doctorId, required this.patientId, Key? key}) : super(key: key);

  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  late GoogleDriveService _googleDriveService;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

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
      print('Error initializing Google Drive service: $e');
    }
  }

  Future<void> _uploadFile() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        print('No file selected');
        return;
      }

      final file = File(pickedFile.path);
      final fileUrl = await _googleDriveService.uploadFile(file, widget.doctorId, widget.patientId);

      if (fileUrl != null) {
        // Save photo details to Firestore
        await FirebaseFirestore.instance.collection('photos').add({
          'url': fileUrl,
          'doctorId': widget.doctorId,
          'patientId': widget.patientId,
          'name': _nameController.text,
          'description': _descriptionController.text,
        });

        print('File URL saved to Firestore: $fileUrl');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File uploaded successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload file')));
      }
    } catch (e) {
      print('Error uploading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading file')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Photo'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadFile,
              child: Text('Upload Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
