import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../google_drive_service.dart';

class ViewPhotosPage extends StatelessWidget {
  final String doctorId;
  final String patientId;
  final GoogleDriveService googleDriveService;

  const ViewPhotosPage({
    required this.doctorId,
    required this.patientId,
    required this.googleDriveService,
    Key? key,
  }) : super(key: key);

  Future<void> _deletePhoto(BuildContext context, String photoId) async {
    try {
      await googleDriveService.deleteFileFromDrive(photoId);

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .collection('photos')
          .doc(photoId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo supprimée')),
      );
    } catch (e) {
      print('Erreur lors de la suppression de la photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la suppression de la photo')),
      );
    }
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photos'),
        backgroundColor: Color(0xFF084cac),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .collection('photos')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucune photo disponible'));
          }

          var photoDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: photoDocs.length,
            itemBuilder: (context, index) {
              var photoDoc = photoDocs[index];
              var photoData = photoDoc.data() as Map<String, dynamic>;
              var photoUrl = photoData['url'] as String?;
              var photoId = photoDoc.id;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${photoData['position'] ?? 'Pas de Position'}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (photoUrl != null) {
                        _showFullImage(context, photoUrl);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      height: 200,
                      color: Colors.grey[200],
                      child: photoUrl != null
                          ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error);
                        },
                      )
                          : Center(child: Text('Aucune photo disponible')),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deletePhoto(context, photoId),
                  ),
                  Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
