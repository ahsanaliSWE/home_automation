import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/device_controller.dart';

class SettingsScreen extends StatelessWidget {
  final DeviceController deviceController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Power Consumption Threshold Section
              Text(
                "Set Power Consumption Threshold (in watts)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Use Obx here to listen to powerThreshold changes
              Obx(() => Text(
                    "Current Threshold: ${deviceController.powerThreshold.value} watts",
                    style: TextStyle(fontSize: 16),
                  )),
              SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "New Threshold",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    double newThreshold = double.tryParse(value) ?? 0;
                    if (newThreshold > 0) { // Validate positive number
                      deviceController.setPowerThreshold(newThreshold);
                      Get.snackbar("Success", "Threshold updated to $newThreshold watts");
                    } else {
                      Get.snackbar("Error", "Please enter a positive number.");
                    }
                  }
                },
              ),
              SizedBox(height: 30),
        
              // Notification Preferences Section
              Text(
                "Notification Preferences",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
        
              // Use Obx to listen to deviceStatusChange notifications
              Obx(() {
                return SwitchListTile(
                  title: Text("Device Status Change Alerts"),
                  value: deviceController.notificationPreferences.energyThreshold.value,
                  onChanged: (value) {
                    deviceController.updateNotificationPreference(
                      'deviceStatusChange',
                      value,
                    );
                  },
                );
              }),
        
              // Security Alerts Notification Toggle
              Obx(() {
                return SwitchListTile(
                  title: Text("Security Alerts"),
                  value: deviceController.notificationPreferences.energyThreshold.value,
                  onChanged: (value) {
                    deviceController.updateNotificationPreference(
                      'securityAlerts',
                      value,
                    );
                  },
                );
              }),
        
              // Energy Consumption Alerts Notification Toggle
              Obx(() {
                return SwitchListTile(
                  title: Text("Energy Consumption Alerts"),
                  value: deviceController.notificationPreferences.energyThreshold.value,
                  onChanged: (value) {
                    deviceController.updateNotificationPreference(
                      'energyThreshold',
                      value,
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
