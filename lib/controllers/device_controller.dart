import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/device.dart';
import '../models/device_usage.dart';
import '../models/notification_preference.dart';
import '../utils/notifications_service.dart';

class DeviceController extends GetxController {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<Device> devices = RxList<Device>();
  RxList<DeviceUsage> deviceUsageLogs = RxList<DeviceUsage>();
  RxDouble totalPowerConsumption =
      0.0.obs; // Total power consumption (in watts)
  RxDouble powerThreshold =
      1000.0.obs; // Observed power threshold (default 1000 watts)
  RxBool isThresholdCrossed =
      false.obs; // Track if the threshold has been crossed
  NotificationPreferences notificationPreferences =
      NotificationPreferences(); // Initialize notification preferences

  // Get the currently authenticated user ID
  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    // Load devices and notification preferences from Firestore when the controller is initialized
    loadDevices();
    loadNotificationPreferences();
  }

  // Load all devices for the authenticated user from Firestore
  void loadDevices() async {
    if (userId.isEmpty) {
      Get.snackbar("Error", "User not authenticated");
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .get();

      devices.clear();
      for (var doc in snapshot.docs) {
        devices.add(Device.fromJson(doc.data()..['id'] = doc.id));
      }

      // Recalculate total power consumption whenever devices are loaded
      calculateTotalPowerConsumption();
    } catch (e) {
      Get.snackbar("Error", "Failed to load devices: $e");
    }
  }

  // Get a device by its ID
  Device? getDeviceById(String id) {
    try {
      return devices.firstWhere((device) => device.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method to calculate total power consumption
  void calculateTotalPowerConsumption() {
    double total = 0;

    // Sum up the power consumption of all devices that are "on"
    for (var device in devices) {
      if (device.status == "on") {
        total += device
            .powerConsumption; // Ensure that the Device model has a `powerConsumption` attribute
      }
    }

    totalPowerConsumption.value =
        total; // Set the value of totalPowerConsumption
    print("Total Power Consumption: $total watts");

    // Check if the total power consumption exceeds the threshold
    _checkPowerThreshold(total);
  }

  // Check if the power threshold is crossed and trigger notifications accordingly
  void _checkPowerThreshold(double totalPower) {
    if (totalPower > powerThreshold.value) {
      // Access the value using .value
      // If the threshold is exceeded and wasn't already crossed, trigger the notification
      if (!isThresholdCrossed.value) {
        _triggerPowerNotification(totalPower);
        isThresholdCrossed.value = true;
      }
    } else {
      // Reset the thresholdCrossed flag when power consumption falls below the threshold
      isThresholdCrossed.value = false;
    }
  }

  // Trigger a notification when power consumption exceeds the threshold
  void _triggerPowerNotification(double totalPower) {
    NotificationService.showNotification(
      id: 1000, // Unique ID for power threshold notifications
      title: "Power Consumption Alert",
      body:
          "Total power consumption has exceeded ${powerThreshold.value} watts. Current usage: $totalPower watts.",
    );
    // Log this notification in Firestore
    NotificationService().logNotification(
      'power_threshold_exceeded',
      'power_consumption', // Can be adjusted based on your device identification
      "Total power consumption has exceeded ${powerThreshold.value} watts. Current usage: $totalPower watts.",
    );
  }

  @override
  void toggleDeviceStatus(String deviceId, String newStatus) async {
    if (userId.isEmpty) {
      Get.snackbar("Error", "User not authenticated");
      return;
    }

    try {
      // Fetch the device document from Firestore
      DocumentSnapshot deviceDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(deviceId)
          .get();

      if (!deviceDoc.exists) {
        Get.snackbar("Error", "Device not found");
        return;
      }

      // Cast the document data to Map<String, dynamic>
      Map<String, dynamic>? deviceData =
          deviceDoc.data() as Map<String, dynamic>?;

      // Get the device name from the document data
      String deviceName = deviceData?['deviceName'] ?? 'Unknown Device';

      // Update the device status in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(deviceId)
          .update({'status': newStatus});

      // Update the local device state
      Device? device = getDeviceById(deviceId);
      if (device != null) {
        device.status = newStatus;
        devices.refresh();
      }

      // Log the notification with the device name
      await NotificationService().logNotification(
        'status_change',
        deviceName, // Use the device name here
        'Device $deviceName status changed to $newStatus.',
      );

      // Calculate total power consumption whenever a device is toggled
      calculateTotalPowerConsumption();
    } catch (e) {
      Get.snackbar("Error", "Failed to update device status: $e");
    }
  }

  // Add a new device to Firestore
  void addDevice(Device newDevice) async {
    if (userId.isEmpty) {
      Get.snackbar("Error", "User not authenticated");
      return;
    }

    try {
      // Add the new device to Firestore under the authenticated user's collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .add(newDevice.toJson());

      // Refresh the devices list after adding
      loadDevices();
      Get.snackbar("Success", "Device added successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to add device: $e");
    }
  }

  // Load energy usage logs for a specific device
  void loadEnergyUsageLogs(String deviceId) async {
    if (userId.isEmpty) {
      Get.snackbar("Error", "User not authenticated");
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(deviceId)
          .collection('energy_usage')
          .orderBy('timestamp', descending: true)
          .get();

      deviceUsageLogs.clear();
      for (var doc in snapshot.docs) {
        deviceUsageLogs.add(DeviceUsage.fromJson(doc.data()..['id'] = doc.id));
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load energy usage logs: $e");
    }
  }

  // Method to add energy usage logs to a device
  void addEnergyUsage(String deviceId, double energyConsumed) async {
    if (userId.isEmpty) {
      Get.snackbar("Error", "User not authenticated");
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(deviceId)
          .collection('energy_usage')
          .add({
        'deviceId': deviceId,
        'energyConsumed': energyConsumed,
        'timestamp': DateTime.now(),
      });

      // Optionally, reload the usage logs after adding a new entry
      loadEnergyUsageLogs(deviceId);
    } catch (e) {
      Get.snackbar("Error", "Failed to log energy usage: $e");
    }
  }

  // Method to delete a device from Firestore and the local list
  void deleteDevice(String deviceId) async {
    if (userId.isEmpty) {
      Get.snackbar("Error", "User not authenticated");
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(deviceId)
          .delete();

      // Remove the device from the local list
      devices.removeWhere((device) => device.id == deviceId);
      Get.snackbar("Success", "Device deleted successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete device: $e");
    }
  }

  void logNotification(String type, String deviceId, String description) async {
    if (userId.isEmpty) {
      Get.snackbar("Error", "User not authenticated");
      return;
    }

    try {
      await _firestore.collection('notifications').add({
        'type': type,
        'deviceId': deviceId,
        'description': description,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to log notification: $e");
    }
  }

// Call this method when a security breach occurs
  void simulateSecurityBreach(String deviceId) {
    logNotification(
      'security_breach',
      deviceId,
      'Security breach detected on device $deviceId!',
    );
  }

  void loadNotificationPreferences() async {
    // Code to fetch preferences from Firestore
    // Assuming you've fetched a Map<String, dynamic> json from Firestore
    Map<String, dynamic> json = {}; // Fetch this from Firestore

    notificationPreferences = NotificationPreferences.fromJson(json);
  }

  // Update user notification preferences
  void updateNotificationPreference(String preferenceType, bool value) {
    switch (preferenceType) {
      case 'deviceStatusChange':
        notificationPreferences.deviceStatusChange.value =
            value; // Update the observable
        break;
      case 'securityAlerts':
        notificationPreferences.securityAlerts.value =
            value; // Update the observable
        break;
      case 'energyThreshold':
        notificationPreferences.energyThreshold.value =
            value; // Update the observable
        break;
    }

    // Save preferences to Firestore whenever a change is made
    saveNotificationPreferences(); // Call to save preferences
  }

// Save notification preferences to Firestore
  void saveNotificationPreferences() async {
    if (userId.isEmpty) {
      Get.snackbar("Error", "User not authenticated");
      return;
    }

    try {
      // Save the notification preferences to Firestore
      await _firestore.collection('users').doc(userId).set(
        {
          'notificationPreferences': notificationPreferences.toJson(),
        },
        SetOptions(
            merge:
                true), // Use merge to update only the notification preferences
      );

      Get.snackbar("Success", "Notification preferences updated successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to update notification preferences: $e");
    }
  }

  // Set a new power threshold
  void setPowerThreshold(double newThreshold) {
    powerThreshold.value = newThreshold; // Update the observable value
    // Optionally save new threshold to Firestore
    savePowerThreshold();
  }

  // Save the power threshold to Firestore
  void savePowerThreshold() async {
    if (userId.isEmpty) {
      return; // User not authenticated
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'powerThreshold': powerThreshold.value, // Save the value to Firestore
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to save power threshold: $e");
    }
  }
}
