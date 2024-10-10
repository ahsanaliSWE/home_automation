
import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String id;
  final String type; // To differentiate between breach and status change
  final String deviceId;
  final String description;
  final DateTime timestamp;

  Notification({
    required this.id,
    required this.type,
    required this.deviceId,
    required this.description,
    required this.timestamp,
  });

  // Create a Notification from JSON
  factory Notification.fromJson(Map<String, dynamic> json, String id) {
    return Notification(
      id: id,
      type: json['type'],
      deviceId: json['deviceId'],
      description: json['description'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}