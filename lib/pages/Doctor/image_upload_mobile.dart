import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../google_drive_service.dart';

class UploadMobile {
  final BuildContext context;
  final GoogleDriveService googleDriveService;
  final ImagePicker picker;

  UploadMobile({
    required this.context,
    required this.googleDriveService,
    required this.picker,
  });

  Future<void> uploadImageMobile(
      String doctorId,
      String patientId,
      String position,
      {
        ImageSource source = ImageSource.gallery,
      }) async {
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      final selectedFile = File(image.path);

      final fileName = '${patientId.padLeft(3, '0')}_${_getPhotoCode(position)}_001.jpg';

      final fileUrl = await googleDriveService.uploadFile(
        selectedFile,
        doctorId,
        patientId,
        fileName: fileName,
      );

      if (fileUrl != null) {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .collection('photos')
            .add({
          'url': fileUrl,
          'doctorId': doctorId,
          'position': position,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo ajoutée avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Une erreur s\'est produite')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: aucune image sélectionnée')),
      );
    }
  }

  String _getPhotoCode(String position) {
    // Mapping positions to their codes
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
        return 'NA'; // Fallback in case of unknown position
    }
  }
}
