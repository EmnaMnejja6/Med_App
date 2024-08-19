import 'package:cloud_firestore/cloud_firestore.dart';

class ApprovalRequest {
  final String id;
  final String status;
  final String email;
  final String password; 
  final String role;
  final String lastName;
  final String firstName;

  ApprovalRequest({
    required this.id,
    required this.status,
    required this.email,
    required this.password, 
    required this.role,
    required this.lastName,
    required this.firstName,
  });

  factory ApprovalRequest.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return ApprovalRequest(
      id: doc.id,
      status: data['status'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '', 
      role: data['role'] ?? '',
      lastName: data['nom'] ?? '',
      firstName: data['prenom'] ?? '',
    );
  }
}
