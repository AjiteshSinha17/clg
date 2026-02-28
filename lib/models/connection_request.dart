import 'package:cloud_firestore/cloud_firestore.dart';

/// Status of a connection request between two users.
enum ConnectionStatus { pending, accepted, rejected }

/// Firestore document: connection_requests collection.
/// Used for: send request, accept/reject, then create chat on accept.
class ConnectionRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final ConnectionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ConnectionRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory ConnectionRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final statusStr = data['status'] as String? ?? 'pending';
    ConnectionStatus status = ConnectionStatus.pending;
    if (statusStr == 'accepted') status = ConnectionStatus.accepted;
    if (statusStr == 'rejected') status = ConnectionStatus.rejected;

    return ConnectionRequest(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      toUserId: data['toUserId'] ?? '',
      status: status,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  bool get isPending => status == ConnectionStatus.pending;
  bool get isAccepted => status == ConnectionStatus.accepted;
}
