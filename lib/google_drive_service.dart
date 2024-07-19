import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart' as auth_io;

class GoogleDriveService {
  final String _rootFolderId = '1MKbFFuIEAB3T-jUMIS_DjyHjzOgrLKDC'; // Replace with your Google Drive folder ID
  late auth.ServiceAccountCredentials _credentials;
  final List<String> _scopes = [drive.DriveApi.driveFileScope];

  GoogleDriveService(String credentialsJson) {
    _credentials = auth.ServiceAccountCredentials.fromJson(credentialsJson);
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    try {
      final client = await auth_io.clientViaServiceAccount(_credentials, _scopes);
      return drive.DriveApi(client);
    } catch (e) {
      print('Error creating Drive API client: $e');
      return null;
    }
  }

  Future<drive.File?> _createFolder(String folderName, String parentId) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      return null;
    }

    final driveFile = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = [parentId];

    try {
      return await driveApi.files.create(driveFile);
    } catch (e) {
      print('Error creating folder: $e');
      return null;
    }
  }

  Future<String?> _getFolderId(String folderName, String parentId) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      return null;
    }

    try {
      final query = "mimeType = 'application/vnd.google-apps.folder' and name = '$folderName' and '$parentId' in parents and trashed = false";
      final fileList = await driveApi.files.list(q: query);
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id;
      }
    } catch (e) {
      print('Error checking for folder existence: $e');
    }

    return null;
  }

  Future<String> _ensureFolderExists(String folderName, String parentId) async {
    String? folderId = await _getFolderId(folderName, parentId);
    if (folderId == null) {
      final folder = await _createFolder(folderName, parentId);
      folderId = folder?.id;
    }
    return folderId!;
  }

  Future<String?> uploadFile(File file, String doctorId, String patientId) async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        return null;
      }

      // Ensure doctor folder exists
      final doctorFolderId = await _ensureFolderExists(doctorId, _rootFolderId);

      // Ensure patient folder exists within the doctor folder
      final patientFolderId = await _ensureFolderExists(patientId, doctorFolderId);

      final media = drive.Media(file.openRead(), file.lengthSync());
      final driveFile = drive.File()
        ..name = path.basename(file.path)
        ..parents = [patientFolderId]
        ..mimeType = 'image/jpeg'; // Specify the MIME type of the file

      final result = await driveApi.files.create(driveFile, uploadMedia: media);

      // Grant public access to the file
      await driveApi.permissions.create(
        drive.Permission.fromJson({
          'role': 'reader',
          'type': 'anyone',
        }),
        result.id!,
      );

      final fileUrl = 'https://drive.google.com/uc?export=view&id=${result.id}';
      return fileUrl;
    } catch (e) {
      print('Error uploading file to Google Drive: $e');
      return null;
    }
  }
}
