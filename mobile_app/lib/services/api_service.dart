import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/hazard.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class RecentUpload {
  final double lat;
  final double lng;
  final DateTime timestamp;

  RecentUpload(this.lat, this.lng, this.timestamp);
}

class ApiService {
  final StorageService _storageService;
  final List<RecentUpload> _recentUploads = [];

  ApiService(this._storageService);

  /// Get authorization header with JWT token
  Map<String, String> _getAuthHeaders() {
    final token = _storageService.getToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// Check if upload is duplicate
  bool _isDuplicate(double lat, double lng, DateTime timestamp) {
    for (var upload in _recentUploads) {
      final distance = _calculateDistance(lat, lng, upload.lat, upload.lng);
      final timeDiff = timestamp.difference(upload.timestamp).inSeconds;

      if (distance < DUPLICATE_DISTANCE_METERS &&
          timeDiff < DUPLICATE_TIME_SECONDS) {
        return true;
      }
    }
    return false;
  }

  /// Calculate distance between two points (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Earth radius in meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = (dLat / 2).sin() * (dLat / 2).sin() +
        _toRadians(lat1).cos() *
            _toRadians(lat2).cos() *
            (dLon / 2).sin() *
            (dLon / 2).sin();

    final c = 2 * a.sqrt().asin();
    return R * c;
  }

  double _toRadians(double degrees) {
    return degrees * 3.14159265359 / 180;
  }

  /// Upload hazard detection
  Future<String?> uploadHazard({
    required File imageFile,
    required double latitude,
    required double longitude,
    required double confidence,
    required DateTime timestamp,
    required String deviceId,
  }) async {
    try {
      // Check for duplicates
      if (_isDuplicate(latitude, longitude, timestamp)) {
        print('Duplicate detection - skipping upload');
        return 'duplicate';
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$API_BASE_URL/api/v1/hazards'),
      );

      // Add headers
      request.headers.addAll(_getAuthHeaders());

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      // Add form fields
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['confidence'] = confidence.toString();
      request.fields['timestamp'] = timestamp.toIso8601String();
      request.fields['device_id'] = deviceId;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Add to recent uploads
        _recentUploads.add(RecentUpload(latitude, longitude, timestamp));
        if (_recentUploads.length > 50) {
          _recentUploads.removeAt(0);
        }

        return data['hazard_id'];
      } else {
        print('Upload failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  /// Get nearby hazards
  Future<List<Hazard>> getNearbyHazards(
    double latitude,
    double longitude, {
    double radiusKm = NEARBY_RADIUS_KM,
    int limit = 100,
  }) async {
    try {
      final uri = Uri.parse('$API_BASE_URL/api/v1/hazards/nearby').replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'radius_km': radiusKm.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(uri, headers: _getAuthHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hazardsList = data['hazards'] as List;
        return hazardsList.map((json) => Hazard.fromJson(json)).toList();
      } else {
        print('Failed to fetch hazards: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching hazards: $e');
      return [];
    }
  }

  /// Get specific hazard details
  Future<Hazard?> getHazardDetail(String hazardId) async {
    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/api/v1/hazards/$hazardId'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Hazard.fromJson(data);
      } else {
        print('Failed to fetch hazard detail: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching hazard detail: $e');
      return null;
    }
  }
}
