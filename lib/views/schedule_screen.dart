import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/schedule_controller.dart';
import '../models/schedule.dart';

class ScheduleScreen extends StatelessWidget {
  final String deviceId; // The specific device ID for which the schedule is being managed
  final ScheduleController scheduleController = Get.put(ScheduleController());
  
  // Time values for the schedule
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  ScheduleScreen({required this.deviceId});

  @override
  Widget build(BuildContext context) {
    // Fetch schedules for the given device ID
    scheduleController.fetchSchedulesForDevice(deviceId);

    return Scaffold(
      appBar: AppBar(title: Text("Manage Schedules for Device $deviceId")),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (scheduleController.schedules.isEmpty) {
                return Center(child: Text("No schedules found for this device."));
              }
              return ListView.builder(
                itemCount: scheduleController.schedules.length,
                itemBuilder: (context, index) {
                  var schedule = scheduleController.schedules[index];
                  return ListTile(
                    title: Text("Start: ${schedule.startTime} - End: ${schedule.endTime}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => scheduleController.deleteSchedule(schedule.id!),
                    ),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("Add a new schedule for this device"),
                SizedBox(height: 10),
                // Start Time Picker Button
                ElevatedButton(
                  onPressed: () async {
                    startTime = await selectTime(context, "Select Start Time");
                  },
                  child: Text(
                    startTime != null
                        ? "Start Time: ${startTime!.format(context)}"
                        : "Select Start Time",
                  ),
                ),
                SizedBox(height: 10),
                // End Time Picker Button
                ElevatedButton(
                  onPressed: () async {
                    endTime = await selectTime(context, "Select End Time");
                  },
                  child: Text(
                    endTime != null
                        ? "End Time: ${endTime!.format(context)}"
                        : "Select End Time",
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (startTime != null && endTime != null) {
                      var newSchedule = Schedule(
                        deviceId: deviceId,
                        startTime: startTime!.format(context),
                        endTime: endTime!.format(context),
                        isRecurring: false,
                      );
                      scheduleController.addSchedule(newSchedule);
                    } else {
                      Get.snackbar("Invalid Time", "Please select start and end times.");
                    }
                  },
                  child: Text("Add Schedule"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Utility method to show a TimePicker dialog and return the selected time
  Future<TimeOfDay?> selectTime(BuildContext context, String title) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: title, // Optional text displayed at the top of the TimePicker
    );
  }
}
