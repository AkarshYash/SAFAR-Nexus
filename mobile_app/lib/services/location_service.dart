import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Check and request location permission
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check permission
      if (!await hasPermission()) {
        final granted = await requestPermission();
        if (!granted) {
          print('Location permission denied');
          return null;
        }
      }

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get position stream for continuous updates
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}
