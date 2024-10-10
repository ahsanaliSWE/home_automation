import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/device_controller.dart';
import '../models/device.dart';

class AddDeviceScreen extends StatefulWidget {
  @override
  _AddDeviceScreenState createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final nameController = TextEditingController();
  final typeController = TextEditingController();
  final powerController = TextEditingController(); // New field for power consumption
  final DeviceController deviceController = Get.find();

  String selectedDeviceName = "Custom"; // Selected device name from dropdown
  String selectedDeviceType = "Light"; // Selected device type from dropdown
  bool isCustomDeviceName = false; // Flag to show/hide custom device name field

  // Prebuilt device names
  final List<String> deviceNames = [
    "Custom", // Custom option for user-defined device names
    "Living Room Light",
    "Bedroom Fan",
    "Smart TV",
    "Air Conditioner",
  ];

  // Prebuilt device types
  final List<String> deviceTypes = [
    "Light",
    "Fan",
    "Television",
    "Air Conditioner",
    "Heater",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Device"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown for Prebuilt Device Names
            DropdownButtonFormField<String>(
              value: selectedDeviceName,
              items: deviceNames.map((String name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDeviceName = newValue!;
                  isCustomDeviceName = selectedDeviceName == "Custom";
                  if (!isCustomDeviceName) {
                    nameController.text = selectedDeviceName; // Automatically fill the text field
                  } else {
                    nameController.clear();
                  }
                });
              },
              decoration: InputDecoration(labelText: "Select Device Name"),
            ),
            SizedBox(height: 20),

            // Show custom device name input field if "Custom" is selected
            if (isCustomDeviceName)
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Custom Device Name"),
              ),
            SizedBox(height: 20),

            // Dropdown for Device Type
            DropdownButtonFormField<String>(
              value: selectedDeviceType,
              items: deviceTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDeviceType = newValue!;
                });
              },
              decoration: InputDecoration(labelText: "Select Device Type"),
            ),
            SizedBox(height: 20),

            // Input field for Power Consumption
            TextField(
              controller: powerController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Power Consumption (Watts)",
                hintText: "e.g., 60",
              ),
            ),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Validate input fields
                if ((isCustomDeviceName && nameController.text.isEmpty) ||
                    powerController.text.isEmpty) {
                  Get.snackbar("Error", "Please enter all the required fields");
                  return;
                }

                // Create a new device object
                Device newDevice = Device(
                  deviceName: isCustomDeviceName ? nameController.text.trim() : selectedDeviceName,
                  deviceType: selectedDeviceType,
                  status: "off", // Default status is "off"
                  powerConsumption: int.tryParse(powerController.text.trim()) ?? 0,
                );

                // Call the addDevice method to add it to Firestore
                deviceController.addDevice(newDevice);

                // Go back to the HomeScreen
                Get.back();
              },
              child: Text("Add Device"),
            ),
          ],
        ),
      ),
    );
  }
}
