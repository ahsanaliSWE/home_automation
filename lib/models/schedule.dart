class Schedule {
  String? id;
  String deviceId;
  String startTime;
  String endTime;
  bool isRecurring;

  Schedule({
    this.id,
    required this.deviceId,
    required this.startTime,
    required this.endTime,
    this.isRecurring = false,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String?,
      deviceId: json['deviceId'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isRecurring: json['isRecurring'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'startTime': startTime,
      'endTime': endTime,
      'isRecurring': isRecurring,
    };
  }
}
