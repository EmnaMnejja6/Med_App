import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewPhotosPage extends StatelessWidget {
  final String doctorId;
  final String patientId;

  const ViewPhotosPage({required this.doctorId, required this.patientId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photos'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('patients').doc(patientId).get(),
        builder: (context, patientSnapshot) {
          if (patientSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (patientSnapshot.hasError) {
            return Center(child: Text('Error: ${patientSnapshot.error}'));
          }

          if (!patientSnapshot.hasData || !patientSnapshot.data!.exists) {
            return Center(child: Text('Patient not found'));
          }

          var patientData = patientSnapshot.data!;
          var patientName = '${patientData['Nom']} ${patientData['Prenom']}';

          // Fetch photos URLs from Firestore
          var photosRef = FirebaseFirestore.instance.collection('photos');
          return StreamBuilder<QuerySnapshot>(
            stream: photosRef.where('patientId', isEqualTo: patientId).snapshots(),
            builder: (context, photosSnapshot) {
              if (photosSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (photosSnapshot.hasError) {
                return Center(child: Text('Error: ${photosSnapshot.error}'));
              }

              var photoDocs = photosSnapshot.data?.docs ?? [];
              if (photoDocs.isEmpty) {
                return Center(child: Text('No photos found'));
              }

              return ListView.builder(
                itemCount: photoDocs.length,
                itemBuilder: (context, index) {
                  var photo = photoDocs[index];
                  var description = photo['description'] ?? '';
                  var photoUrl = photo['url'];

                  return ListTile(
                    title: Text('Photo ${index + 1}'),
                    subtitle: Text(description),
                    leading: Image.network(
                      photoUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ViewPhotosPage(doctorId: 'doctorId', patientId: 'patientId'),
  ));
}
