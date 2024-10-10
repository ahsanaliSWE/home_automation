import 'package:get/get.dart';

class NotificationPreferences {
  RxBool deviceStatusChange; // Observable for device status change alerts
  RxBool securityAlerts;      // Observable for security alerts
  RxBool energyThreshold;     // Observable for energy threshold alerts

  NotificationPreferences({
    bool deviceStatusChange = true, // Default value
    bool securityAlerts = true,      // Default value
    bool energyThreshold = true,     // Default value
  })  : deviceStatusChange = deviceStatusChange.obs, // Initialize as RxBool
        securityAlerts = securityAlerts.obs,         // Initialize as RxBool
        energyThreshold = energyThreshold.obs;       // Initialize as RxBool

  // Method to convert the preferences to a JSON format for Firestore
  Map<String, dynamic> toJson() {
    return {
      'deviceStatusChange': deviceStatusChange.value, // Access the value
      'securityAlerts': securityAlerts.value,         // Access the value
      'energyThreshold': energyThreshold.value,       // Access the value
    };
  }

  // Method to create preferences from a JSON format
  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      deviceStatusChange: json['deviceStatusChange'] ?? true,
      securityAlerts: json['securityAlerts'] ?? true,
      energyThreshold: json['energyThreshold'] ?? true,
    );
  }
}
