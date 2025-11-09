import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../models/hazard.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  late ApiService _apiService;
  final LocationService _locationService = LocationService();

  LatLng _currentLocation = const LatLng(28.7041, 77.1025); // Default: Delhi
  Set<Marker> _markers = {};
  List<Hazard> _hazards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    final storage = await StorageService.create();
    _apiService = ApiService(storage);

    // Get current location
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    }

    // Load nearby hazards
    await _loadHazards();
  }

  Future<void> _loadHazards() async {
    setState(() => _isLoading = true);

    final hazards = await _apiService.getNearbyHazards(
      _currentLocation.latitude,
      _currentLocation.longitude,
    );

    setState(() {
      _hazards = hazards;
      _markers = _createMarkers(hazards);
      _isLoading = false;
    });
  }

  Set<Marker> _createMarkers(List<Hazard> hazards) {
    final markers = <Marker>{};

    // User location marker
    markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    // Hazard markers
    for (var hazard in hazards) {
      markers.add(
        Marker(
          markerId: MarkerId(hazard.hazardId),
          position: LatLng(hazard.latitude, hazard.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Pothole',
            snippet:
                'Confidence: ${(hazard.confidence * 100).toInt()}% • ${hazard.distanceKm?.toStringAsFixed(1) ?? "?"} km away',
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hazard Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHazards,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 15,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${_hazards.length} hazards nearby',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
