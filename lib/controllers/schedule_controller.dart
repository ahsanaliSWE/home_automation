import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/schedule.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/notifications_service.dart'; // Make sure to import your notification service

class ScheduleController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxList<Schedule> schedules = RxList<Schedule>();

  // Get the currently authenticated user ID
  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    // Optionally, fetch all schedules on initialization
    fetchSchedules();
  }

  // Fetch all schedules for the authenticated user
  void fetchSchedules() async {
    if (userId.isEmpty) {
      Get.snackbar("Error", "User not authenticated");
      return;
    }

    try {
      var scheduleData = await firestore.collection('users')
          .doc(userId)
          .collection('schedules')
          .get();

      schedules.value = scheduleData.docs
          .map((doc) => Schedule.fromJson(doc.data()..['id'] = doc.id))
          .toList();
          
      // Schedule notifications for fetched schedules
      scheduleNotifications();

    } catch (e) {
      Get.snackbar("Error", "Failed to load schedules: $e");
    }
  }

  // Fetch schedules for a specific device by device ID
  void fetchSchedulesForDevice(String deviceId) async {
    if (userId.isEmpty) {
      Get.snackbar("Error", "User not authenticated");
      return;
    }

    try {
      var scheduleData = await firestore.collection('users')
          .doc(userId)
          .collection('schedules')
          .where('deviceId', isEqualTo: deviceId) // Filter by deviceId
          .get();

      schedules.value = scheduleData.docs
          .map((doc) => Schedule.fromJson(doc.data()..['id'] = doc.id))
          .toList();
          
      // Schedule notifications for fetched schedules
      scheduleNotifications();

    } catch (e) {
      Get.snackbar("Error", "Failed to load schedules for device: $e");
    }
  }

  // Add a new schedule
  void addSchedule(Schedule schedule) async {
    if (userId.isEmpty) {
      Get.snackbar("Error", "User not authenticated");
      return;
    }

    try {
      await firestore.collection('users')
          .doc(userId)
          .collection('schedules')
          .add(schedule.toJson());

      // Schedule notification for the new schedule
      scheduleNotification(schedule);
      
      fetchSchedulesForDevice(schedule.deviceId); // Refresh schedules for the specific device
    } catch (e) {
      Get.snackbar("Error", "Failed to add schedule: $e");
    }
  }

  // Schedule notifications for all schedules
  void scheduleNotifications() {
    for (var schedule in schedules) {
      scheduleNotification(schedule);
    }
  }

  void scheduleNotification(Schedule schedule) {
  // Assuming schedule.endTime is a string like "10:30 PM" or "22:30:00"
  
  // Parse the endTime. Adjust this to match the exact format you store in Firestore.
  // Here we assume endTime is in the format of "HH:mm a"
  TimeOfDay endTime = TimeOfDay.fromDateTime(DateFormat.jm().parse(schedule.endTime));

  // Get the current date (or you could use a date associated with the schedule if available)
  DateTime currentDate = DateTime.now();

  // Create a DateTime object for the end of the schedule today
  DateTime scheduleEndDateTime = DateTime(
    currentDate.year,
    currentDate.month,
    currentDate.day,
    endTime.hour,
    endTime.minute,
  );

  // Calculate the notification time (5 minutes before the end time)
  DateTime notificationTime = scheduleEndDateTime.subtract(Duration(minutes: 5));

  // Schedule the notification
  NotificationService.showScheduledNotification(
    id: 1,
    title: "Schedule Reminder",
    body: "Reminder: Your schedule is ending soon at ${schedule.endTime}.",
    scheduledDate: notificationTime,
  );
}

  // Update an existing schedule
  void updateSchedule(String scheduleId, Map<String, dynamic> newData) async {
    if (userId.isEmpty) {
      Get.snackbar("Error", "User not authenticated");
      return;
    }

    try {
      await firestore.collection('users')
          .doc(userId)
          .collection('schedules')
          .doc(scheduleId)
          .update(newData);
      
      fetchSchedules(); // Optionally, refresh all schedules after update
    } catch (e) {
      Get.snackbar("Error", "Failed to update schedule: $e");
    }
  }

  // Delete a schedule by ID
  void deleteSchedule(String scheduleId) async {
    if (userId.isEmpty) {
      Get.snackbar("Error", "User not authenticated");
      return;
    }

    try {
      await firestore.collection('users')
          .doc(userId)
          .collection('schedules')
          .doc(scheduleId)
          .delete();
      schedules.removeWhere((schedule) => schedule.id == scheduleId);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete schedule: $e");
    }
  }
}
