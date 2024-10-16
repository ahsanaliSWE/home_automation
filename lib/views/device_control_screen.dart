import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/device.dart';
import 'schedule_screen.dart';

class DeviceControlScreen extends StatelessWidget {
  final Device device;

  DeviceControlScreen({required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Control ${device.deviceName}")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Device Type: ${device.deviceType}"),
            SizedBox(height: 20),
            Text("Status: ${device.status == "on" ? "On" : "Off"}"),
            SizedBox(height: 20),
            Text("Power Consumption: ${device.powerConsumption} watts"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.to(() => ScheduleScreen(deviceId: device.id!)),
              child: Text("Manage Schedules"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
