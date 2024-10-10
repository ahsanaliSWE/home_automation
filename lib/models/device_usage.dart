import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceUsage {
  String? id;
  String deviceId;
  double energyConsumed; // in kWh
  DateTime timestamp;

  DeviceUsage({
    this.id,
    required this.deviceId,
    required this.energyConsumed,
    required this.timestamp,
  });

  DeviceUsage.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        deviceId = json['deviceId'],
        energyConsumed = json['energyConsumed'],
        timestamp = (json['timestamp'] as Timestamp).toDate();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'energyConsumed': energyConsumed,
      'timestamp': timestamp,
    };
  }
}
