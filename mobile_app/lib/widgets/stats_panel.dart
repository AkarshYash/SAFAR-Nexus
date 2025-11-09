import 'package:flutter/material.dart';

class StatsPanel extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final int detectionCount;
  final bool isAnalyzing;
  final bool isOnline;

  const StatsPanel({
    Key? key,
    this.latitude,
    this.longitude,
    required this.detectionCount,
    required this.isAnalyzing,
    required this.isOnline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GPS Coordinates',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    latitude != null && longitude != null
                        ? '${latitude!.toStringAsFixed(2)}, ${longitude!.toStringAsFixed(2)}'
                        : 'Acquiring GPS...',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Detections',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '$detectionCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAnalyzing ? 'Analyzing...' : 'Ready',
                style: TextStyle(
                  color: isAnalyzing ? Colors.green : Colors.white70,
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: isOnline ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
