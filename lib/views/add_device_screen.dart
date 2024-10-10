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

  String selectedDeviceName = "Custom"; 
  String selectedDeviceType = "Custom"; 
  bool isCustomDeviceName = false; 
  bool isCustomDeviceType = false;

  final List<String> deviceNames = [
    "Custom", 
    "Living Room Light",
    "Bedroom Fan",
    "Smart TV",
    "Air Conditioner",
  ];

  final List<String> deviceTypes = [
    "Custom", 
    "Light",
    "Fan",
    "Television",
    "Air Conditioner",
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
            // Device Name Dropdown
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

            // Custom Device Name TextField
            if (isCustomDeviceName)
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Custom Device Name"),
              ),
            SizedBox(height: 20),

            // Device Type Dropdown
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
                  isCustomDeviceType = selectedDeviceType == "Custom";
                  if (!isCustomDeviceType) {
                    typeController.text = selectedDeviceType;
                  } else {
                    typeController.clear();
                  }
                });
              },
              decoration: InputDecoration(labelText: "Select Device Type"),
            ),
            SizedBox(height: 20),

            // Custom Device Type TextField
            if (isCustomDeviceType)
              TextField(
                controller: typeController,
                decoration: InputDecoration(labelText: "Custom Device Type"),
              ),
            SizedBox(height: 20),

            // Power Consumption TextField
            TextField(
              controller: powerController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Power Consumption (Watts)",
                hintText: "e.g., 60",
              ),
            ),
            SizedBox(height: 30),

            // Add Device Button
            ElevatedButton(
              onPressed: () {
                // Validate input fields
                if ((isCustomDeviceName && nameController.text.isEmpty) ||
                    (isCustomDeviceType && typeController.text.isEmpty) ||
                    powerController.text.isEmpty) {
                  Get.snackbar("Error", "Please enter all the required fields");
                  return;
                }

                // Validate power consumption input
                final power = int.tryParse(powerController.text.trim());
                if (power == null || power <= 0) {
                  Get.snackbar("Error", "Please enter a valid power consumption value.");
                  return;
                }

                // Create a new Device object
                Device newDevice = Device(
                  deviceName: isCustomDeviceName ? nameController.text.trim() : selectedDeviceName,
                  deviceType: isCustomDeviceType ? typeController.text.trim() : selectedDeviceType,
                  status: "off",
                  powerConsumption: power,
                );

                // Add device through the controller
                deviceController.addDevice(newDevice);

                // Navigate back after adding the device
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
