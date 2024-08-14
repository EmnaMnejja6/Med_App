import 'package:cloud_firestore/cloud_firestore.dart';

class DeletionRequest {
  final String id;
  final String requesterUid;
  final String targetUid;
  final String status;

  DeletionRequest({
    required this.id,
    required this.requesterUid,
    required this.targetUid,
    required this.status,
  });

  factory DeletionRequest.fromDocument(DocumentSnapshot doc) {
    return DeletionRequest(
      id: doc.id,
      requesterUid: doc['requesterUid'],
      targetUid: doc['targetUid'],
      status: doc['status'],
    );
  }
}
