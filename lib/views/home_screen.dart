import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/device_controller.dart';
import '../utils/notifications_service.dart';
import 'add_device_screen.dart';
import 'device_control_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeviceController deviceController = Get.put(DeviceController());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Set<String> selectedDevices = {}; // Store IDs of selected devices

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Home Automation"),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Get.to(() => NotificationScreen());
            },
          ),
        ],
      ),
      // Adding Drawer to the HomeScreen
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // User Accounts Header - for displaying user profile info
            SizedBox(
              height: 50,
            ),
            // Drawer Menu Options
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Get.to(() => ProfileScreen()); // Navigate to ProfileScreen
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Get.to(() => SettingsScreen()); // Navigate to SettingsScreen
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Sign Out"),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                _confirmSignOut(); // Show the confirmation dialog
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Display Total Power Consumption
          Obx(() {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Total Power Consumption: ${deviceController.totalPowerConsumption.value} watts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
          }),
          Obx(() {
            if (deviceController.devices.isEmpty) {
              return Center(
                child: const Text(
                    "No devices found. Add a new device to get started."),
              );
            }
            return Expanded(
              child: ListView.builder(
                itemCount: deviceController.devices.length,
                itemBuilder: (context, index) {
                  var device = deviceController.devices[index];
                  return ListTile(
                    title: Text(device.deviceName),
                    subtitle: Text("Type: ${device.deviceType}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: device.status == "on",
                          onChanged: (val) {
                            deviceController.toggleDeviceStatus(
                              device.id!,
                              val ? "on" : "off",
                            );

                            // Trigger a notification when a device is turned on/off
                            NotificationService.showNotification(
                              id: index,
                              title: "Device Status Changed",
                              body:
                                  "${device.deviceName} has been turned ${val ? "on" : "off"}",
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Show a confirmation dialog before deleting the individual device
                            Get.dialog(
                              AlertDialog(
                                title: Text("Delete Device"),
                                content: Text(
                                    "Are you sure you want to delete the device '${device.deviceName}'?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back(); // Close the dialog
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deviceController.deleteDevice(device.id!);
                                      Get.back(); // Close the dialog after deletion
                                    },
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to the device control screen
                      Get.to(DeviceControlScreen(device: device));
                    },
                  );
                },
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          icon: Icon(Icons.add),
          label: Text("Add Device"),
          onPressed: () {
            Get.to(AddDeviceScreen()); // Navigate to Add Device Screen
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  // Method to show a confirmation dialog before signing out
  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Sign-Out"),
          content: Text("Are you sure you want to sign out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _signOut(); // Call the sign-out method
              },
              child: Text("Sign Out"),
            ),
          ],
        );
      },
    );
  }

  // Sign-out method
  Future<void> _signOut() async {
    await _auth.signOut();
    Get.offAllNamed('/login'); // Redirect to login screen
  }
}
