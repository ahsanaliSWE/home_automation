import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

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

  factory Notification.fromJson(Map<String, dynamic> json, String id) {
    return Notification(
      id: id,
      type: json['type'],
      deviceId: json['deviceId'],
      description: json['description'],
      // Check if the timestamp is a Timestamp or a String
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'] as String), // Convert from String
    );
  }
}

class NotificationScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to fetch user-specific notifications from Firestore
  Stream<List<Notification>> _fetchNotifications() {
    final userId = _auth.currentUser?.uid; // Get the current user's ID
    if (userId == null) {
      return Stream.value([]); // Return empty list if user is not authenticated
    }

    // Fetch notifications from user's sub-collection
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true) // Fetch latest first
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notification.fromJson(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Method to clear all notifications for the current user
  void _clearAllNotifications() async {
    final userId = _auth.currentUser?.uid; // Get the current user's ID
    if (userId == null) return;

    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    Get.snackbar("Success", "All notifications cleared successfully!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Show a confirmation dialog before clearing notifications
              Get.defaultDialog(
                title: "Clear Notifications",
                middleText: "Are you sure you want to clear all notifications?",
                confirm: TextButton(
                  onPressed: () {
                    _clearAllNotifications();
                    Get.back(); // Close the dialog
                  },
                  child: Text("Yes"),
                ),
                cancel: TextButton(
                  onPressed: () {
                    Get.back(); // Close the dialog
                  },
                  child: Text("No"),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Notification>>(
        stream: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No notifications"));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(
                  notification.type == 'schedule'
                      ? "Scheduled Task for Device: ${notification.deviceId}"
                      : notification.type == 'power_threshold_exceeded'
                          ? "Power Consumption Alert: ${notification.deviceId}"
                          : notification.type == 'status_change'
                              ? "Status Change on Device: ${notification.deviceId}"
                              : "Unknown Notification Type for Device: ${notification.deviceId}",
                ),
                subtitle: Text(
                  "${notification.description}\n${notification.timestamp}",
                  style: TextStyle(color: Colors.grey),
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
