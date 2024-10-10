class Device {
  String? id;
  String deviceName;
  String deviceType;
  String status;
  int powerConsumption; // New field for power consumption

  Device({
    this.id,
    required this.deviceName,
    required this.deviceType,
    required this.status,
    this.powerConsumption = 0, // Default to 0 if not specified
  });

  // Convert from Firestore document to Device object
  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'],
        deviceName: json['deviceName'],
        deviceType: json['deviceType'],
        status: json['status'],
        powerConsumption: json['powerConsumption'] ?? 0,
      );

  // Convert Device object to JSON for Firestore
  Map<String, dynamic> toJson() => {
        'deviceName': deviceName,
        'deviceType': deviceType,
        'status': status,
        'powerConsumption': powerConsumption,
      };
}
