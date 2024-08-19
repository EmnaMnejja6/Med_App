import 'dart:typed_data'; // Importing for Uint8List
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../google_drive_service.dart';

class UploadWeb {
  final BuildContext context;
  final GoogleDriveService googleDriveService;
  final Map<String, String?> imagePaths;
  final bool isLoading;
  final Function(bool) setLoading;

  UploadWeb({
    required this.context,
    required this.googleDriveService,
    required this.imagePaths,
    required this.isLoading,
    required this.setLoading,
  });

  Future<void> pickAndUploadImage(
      String doctorId,
      String patientId,
      String fileName,
      ) async {
    // Sélectionner un fichier à l'aide de file_picker
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      Uint8List? fileBytes = result.files.single.bytes; // Obtenir les octets du fichier
      if (fileBytes != null) {
        await uploadImageWeb(fileBytes, doctorId, patientId, fileName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec du chargement des données de l\'image')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun fichier sélectionné')),
      );
    }
  }

  Future<void> uploadImageWeb(
      Uint8List fileBytes,
      String doctorId,
      String patientId,
      String fileName,
      ) async {
    setLoading(true);

    try {
      final patientIdPadded = patientId.padLeft(3, '0');
      final fileNameWithCode = fileName;

      // Utiliser le service de téléversement
      final fileUrl = await googleDriveService.uploadFile(
        fileBytes, // Transmettre l'Uint8List à la fonction de téléversement
        doctorId,
        patientId,
        fileName: fileNameWithCode,
      );

      if (fileUrl != null) {
        await FirebaseFirestore.instance.collection('photos').add({
          'url': fileUrl,
          'doctorId': doctorId,
          'patientId': patientId,
          'position': fileName,
        });

        imagePaths[fileName] = fileUrl;

        print('URL du fichier sauvegardée dans Firestore : $fileUrl');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fichier téléchargé avec succès !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec du téléchargement du fichier')),
        );
      }
    } catch (e) {
      print('Erreur lors du téléchargement du fichier : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléchargement du fichier : $e')),
      );
    } finally {
      setLoading(false);
    }
  }
}
