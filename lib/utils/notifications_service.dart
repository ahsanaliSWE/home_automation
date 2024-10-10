// notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize Firebase Auth

  static Future<void> initialize() async {
    // Initialize timezone for scheduling
    tz.initializeTimeZones();

    // Set the timezone for Pakistan
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
      },
    );
    // Request notification permissions
    await requestPermissions();

    // Initialize Firebase Cloud Messaging
    await _firebaseMessaging.setAutoInitEnabled(true);
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print("Firebase Messaging Token: $token");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String title = message.notification?.title ?? "New Notification";
      String body = message.notification?.body ?? "You have a new alert";
      _logNotificationToFirestore(title, body);

      showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification?.title ?? "New Notification",
        body: message.notification?.body ?? "You have a new alert",
      );
    });

    // Handle background message actions
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message clicked: ${message.notification?.title ?? ''}");
    });
  }

   // Function to log a new notification
  Future<void> logNotification(String type, String deviceName, String description) async {
    try {
      String? userId = _auth.currentUser?.uid; // Get the current user's ID
      if (userId == null) {
        print("Error: User not authenticated. Cannot log notification.");
        return;
      }

      await _firestore.collection('users').doc(userId).collection('notifications').add({
        'type': type,
        'deviceId': deviceName,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(), // Automatically set server time
      });
      print("Notification logged successfully!");
    } catch (e) {
      print("Failed to log notification: $e");
    }
  }
  // Method to log notification to Firestore
  static Future<void> _logNotificationToFirestore(String title, String body) async {
    try {
      // Get the current authenticated user
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        print("Error: No authenticated user.");
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).collection('notifications').add({
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Notification stored in Firestore.");
    } catch (e) {
      print("Error storing notification: $e");
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'main_channel',
      'Main Channel',
      channelDescription: 'This is the main channel for the app notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true, // Enable sound
      channelShowBadge: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
    );
  }

  static Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Initialize timezone for safety
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

    if (scheduledDate.isBefore(DateTime.now())) {
      print("Scheduled date is in the past.");
      return;
    }

    // Request permissions
    await requestPermissions();

    if (await Permission.ignoreBatteryOptimizations.isGranted) {
      // Convert the scheduled date to the correct time zone
      final tz.TZDateTime scheduledTZDate =
          tz.TZDateTime.from(scheduledDate, tz.local);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'new_scheduled_channel', // Make sure this matches exactly
        'New Scheduled Channel',
        channelDescription:
            'This is a test channel for scheduled notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        channelShowBadge: true,
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      try {
        print("Scheduling notification...");
        print("Current Time: ${DateTime.now()}");
        print("Scheduled Time: $scheduledDate");
        print("Scheduled TZ Time: $scheduledTZDate");

        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTZDate,
          platformDetails,
          // ignore: deprecated_member_use
          androidAllowWhileIdle: true,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        print("Notification scheduled successfully!");
      } catch (e) {
        print("Error scheduling notification: $e");
      }
    } else {
      print("Battery optimization permission is not granted.");
    }
  }

  static Future<void> requestPermissions() async {
    // Request permission for battery optimizations
    var batteryStatus = await Permission.ignoreBatteryOptimizations.status;
    if (batteryStatus.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    // Request permission for exact alarms
    var exactAlarmStatus = await Permission.scheduleExactAlarm.status;
    if (exactAlarmStatus.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    // Check and print permissions status
    batteryStatus = await Permission.ignoreBatteryOptimizations.status;
    exactAlarmStatus = await Permission.scheduleExactAlarm.status;

    print("Battery optimization permission status: $batteryStatus");
    print("Exact alarm permission status: $exactAlarmStatus");
  }

  void requestExactAlarmPermission() async {
    try {
      final result = await MethodChannel('exact_alarm')
          .invokeMethod('requestExactAlarmPermission');
      if (result == 'granted') {
        print("Exact alarm permission granted.");
      } else {
        print("Exact alarm permission not granted.");
      }
    } on PlatformException catch (e) {
      print("Error requesting exact alarm permission: ${e.message}");
    }
  }
}
