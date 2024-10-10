import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/device_controller.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../models/device_usage.dart';

class EnergyMonitoringScreen extends StatelessWidget {
  final String deviceId;
  final DeviceController deviceController = Get.find();

  EnergyMonitoringScreen({required this.deviceId});

  @override
  Widget build(BuildContext context) {
    // Load energy usage logs when the screen is opened
    deviceController.loadEnergyUsageLogs(deviceId);

    return Scaffold(
      appBar: AppBar(
        title: Text("Energy Usage - $deviceId"),
      ),
      body: Obx(() {
        if (deviceController.deviceUsageLogs.isEmpty) {
          return Center(child: Text("No energy usage data available."));
        }

        // Prepare data for the chart
        List<charts.Series<DeviceUsage, DateTime>> series = [
          charts.Series(
            id: "EnergyUsage",
            data: deviceController.deviceUsageLogs,
            domainFn: (DeviceUsage usage, _) => usage.timestamp,
            measureFn: (DeviceUsage usage, _) => usage.energyConsumed,
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          )
        ];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: charts.TimeSeriesChart(
                  series,
                  animate: true,
                  dateTimeFactory: const charts.LocalDateTimeFactory(),
                  behaviors: [
                    charts.ChartTitle('Time'),
                    charts.ChartTitle('Energy (kWh)',
                        behaviorPosition: charts.BehaviorPosition.start),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
