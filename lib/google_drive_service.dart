import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:googleapis_auth/auth_io.dart' as auth_io;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class GoogleDriveService {
  final String _rootFolderId = '1cnZ4NySYK0Cn8Yr9iB94oiHSxaVrerAN';
  late auth.ServiceAccountCredentials _credentials;
  final List<String> _scopes = [drive.DriveApi.driveFileScope];

  GoogleDriveService(String credentialsJson) {
    _credentials = auth.ServiceAccountCredentials.fromJson(credentialsJson);
  }

  Future<drive.DriveApi?> getDriveApi() async {
    try {
      final client = await auth_io.clientViaServiceAccount(
          _credentials, _scopes);
      return drive.DriveApi(client);
    } catch (e) {
      print('Error creating Drive API client: $e');
      return null;
    }
  }

  Future<void> deleteFileFromDrive(String fileId) async {
    try {
      final driveApi = await getDriveApi();
      if (driveApi == null) {
        print('Google Drive API client not available');
        return;
      }

      print('Attempting to delete file from Google Drive with ID: $fileId');
      await driveApi.files.delete(fileId);
      print('File deleted from Google Drive successfully');
    } catch (e) {
      print('Error deleting file from Google Drive: $e');
    }
  }




  Future<drive.File?> createFolder(String folderName, String parentId) async {
    final driveApi = await getDriveApi();
    if (driveApi == null) return null;

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

  Future<String?> getFolderId(String folderName, String parentId) async {
    final driveApi = await getDriveApi();
    if (driveApi == null) return null;

    try {
      final query = "mimeType = 'application/vnd.google-apps.folder' and name = '$folderName' and '$parentId' in parents and trashed = false";
      final fileList = await driveApi.files.list(q: query);
      return fileList.files?.first.id;
    } catch (e) {
      print('Error checking for folder existence: $e');
      return null;
    }
  }

  Future<String> ensureFolderExists(String folderName, String parentId) async {
    String? folderId = await getFolderId(folderName, parentId);
    if (folderId == null) {
      final folder = await createFolder(folderName, parentId);
      folderId = folder?.id;
    }
    return folderId!;
  }


  Future<String?> uploadFile(dynamic file, String doctorId, String patientId, {required String fileName}) async {
    try {
      final driveApi = await getDriveApi();
      if (driveApi == null) return null;

      final doctorFolderId = await ensureFolderExists(doctorId, _rootFolderId);
      final patientFolderId = await ensureFolderExists(patientId, doctorFolderId);

      drive.Media media;
      drive.File driveFile = drive.File()
        ..parents = [patientFolderId]
        ..mimeType = 'image/jpeg'
        ..name = fileName;

      if (file is File) {
        media = drive.Media(file.openRead(), file.lengthSync());
      } else if (file is Uint8List) {
        final stream = Stream.fromIterable([file]);
        media = drive.Media(stream, file.length);
      } else {
        throw Exception('Unsupported file type');
      }

      final result = await driveApi.files.create(driveFile, uploadMedia: media);

      // Grant public access to the file
      await driveApi.permissions.create(
        drive.Permission.fromJson({
          'role': 'reader',
          'type': 'anyone',
        }),
        result.id!,
      );

      return 'https://drive.google.com/uc?export=view&id=${result.id}';
    } catch (e) {
      print('Erreur: $e');
      return null;
    }
  }

  deleteFile(String fileId) {}

/*
Future<String?> uploadFile(File file, String doctorId, String patientId,{required String fileName}) async {
    try {
      final driveApi = await getDriveApi();
      if (driveApi == null) return null;

      // Ensure doctor and patient folders exist
      final doctorFolderId = await ensureFolderExists(doctorId, _rootFolderId);
      final patientFolderId = await ensureFolderExists(patientId, doctorFolderId);

      final media = drive.Media(file.openRead(), file.lengthSync());
      final driveFile = drive.File()
        ..name = path.basename(file.path)
        ..parents = [patientFolderId]
        ..mimeType = 'image/jpeg'
        ..name = fileName;

      final result = await driveApi.files.create(driveFile, uploadMedia: media);

      // Grant public access to the file
      await driveApi.permissions.create(
        drive.Permission.fromJson({
          'role': 'reader',
          'type': 'anyone',
        }),
        result.id!,
      );

      return 'https://drive.google.com/uc?export=view&id=${result.id}';
    } catch (e) {
      print('Error uploading file to Google Drive: $e');
      return null;
    }
  }*/
 }
