# Home Automation

This project is a **Home Automation** that integrates various IoT devices, enabling users to control their home environment through a mobile app. The system allows users to manage devices such as lights, fans, air conditioners, and more. Key features include:

- **Device Control**: Turn devices on/off and control specific device settings.
- **Custom Schedules**: Schedule devices to run at specific times.
- **Energy Monitoring**: Monitor the power consumption of devices.
- **Notifications**: Receive real-time notifications, including maintenance alerts and status updates.
- **User Profiles**: Manage user profiles with Firebase Authentication.
- **Persistent Data Storage**: Data is stored and retrieved using Firebase Firestore.

## Features

1. **Device Management**:
   - Add, update, and control various smart devices.
   - Set power consumption for each device and track their status (on/off).
   
2. **Scheduling**:
   - Schedule devices to automatically turn on/off at predefined times.
   - Display notifications for scheduled tasks, such as maintenance reminders.

3. **Energy Consumption Monitoring**:
   - Monitor and track energy usage of each device.

4. **Notifications**:
   - Receive real-time notifications for system alerts, scheduled maintenance, device updates, and power consumption reports using Firebase Cloud Messaging (FCM).
   - Notifications are logged in Firestore for easy access and tracking.

5. **Profile Management**:
   - Users can view and update their personal profile information (name and phone number).
   - Secure user authentication using Firebase Authentication.

## Tech Stack

- **Flutter**: For building the mobile application UI.
- **Firebase**: 
  - **Firestore**: For storing user data, device details, notifications, etc.
  - **Firebase Authentication**: For secure user authentication and profile management.
  - **Firebase Cloud Messaging (FCM)**: For sending push notifications.
  - **Firebase Functions**: For server-side processing such as sending scheduled notifications.
- **GetX**: State management and navigation.

## Installation

### Prerequisites
- Install Flutter: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
- Create a Firebase project and set up Firebase services such as Firestore, Authentication, and Cloud Messaging.

### Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/ahsanaliSWE/home_automation.git
   cd home-automation
