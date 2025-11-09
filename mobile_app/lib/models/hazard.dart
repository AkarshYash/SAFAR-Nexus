class Hazard {
  final String hazardId;
  final double latitude;
  final double longitude;
  final double confidence;
  final DateTime timestamp;
  final String imageUrl;
  final double? distanceKm;

  Hazard({
    required this.hazardId,
    required this.latitude,
    required this.longitude,
    required this.confidence,
    required this.timestamp,
    required this.imageUrl,
    this.distanceKm,
  });

  factory Hazard.fromJson(Map<String, dynamic> json) {
    return Hazard(
      hazardId: json['hazard_id'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      confidence: json['confidence'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['image_url'],
      distanceKm: json['distance_km']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hazard_id': hazardId,
      'latitude': latitude,
      'longitude': longitude,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'image_url': imageUrl,
      if (distanceKm != null) 'distance_km': distanceKm,
    };
  }
}

class Detection {
  final double x;
  final double y;
  final double width;
  final double height;
  final double confidence;
  final String className;

  Detection({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
    required this.className,
  });
}
