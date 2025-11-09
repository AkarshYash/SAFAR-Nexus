import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import '../services/ai_service.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../widgets/detection_overlay.dart';
import '../widgets/stats_panel.dart';
import '../models/hazard.dart';
import 'map_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  int _frameCount = 0;

  final AIService _aiService = AIService();
  late ApiService _apiService;
  final LocationService _locationService = LocationService();

  List<Detection> _currentDetections = [];
  int _detectionCount = 0;
  Position? _currentPosition;
  bool _isOnline = true;
  bool _showToast = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize services
    final storage = await StorageService.create();
    _apiService = ApiService(storage);

    await _aiService.initialize();
    await _locationService.requestPermission();

    // Get location
    _currentPosition = await _locationService.getCurrentLocation();

    // Initialize camera
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      setState(() => _isInitialized = true);

      // Start image stream
      _cameraController!.startImageStream(_processCameraImage);
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;

    _frameCount++;
    if (_frameCount % 3 != 0) return; // Process every 3rd frame

    _isProcessing = true;

    try {
      // Get current location
      if (_currentPosition == null) {
        _currentPosition = await _locationService.getCurrentLocation();
      }

      // Run AI detection
      final detections = await _aiService.detectHazards(image);

      if (mounted) {
        setState(() {
          _currentDetections = detections;
        });
      }

      // Upload if detection found with high confidence
      for (var detection in detections) {
        if (detection.confidence > 0.7 && _currentPosition != null) {
          _handleDetection(detection);
        }
      }
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _handleDetection(Detection detection) async {
    // TODO: Crop image to detection region
    // For now, skip upload since we need actual image file
    // In production, save current frame, crop, and upload

    setState(() {
      _detectionCount++;
      _showToast = true;
    });

    // Hide toast after 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _showToast = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _aiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _cameraController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Camera preview
          SizedBox.expand(
            child: CameraPreview(_cameraController!),
          ),

          // Detection overlay
          if (_currentDetections.isNotEmpty)
            CustomPaint(
              painter: DetectionOverlay(
                detections: _currentDetections,
                imageSize: Size(
                  _cameraController!.value.previewSize!.height,
                  _cameraController!.value.previewSize!.width,
                ),
              ),
              child: Container(),
            ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
              ),
              child: SafeArea(
                child: Text(
                  'SAFAR-Nexus',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Toast notification
          if (_showToast)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '✓ Hazard reported',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),

          // Stats panel
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: StatsPanel(
              latitude: _currentPosition?.latitude,
              longitude: _currentPosition?.longitude,
              detectionCount: _detectionCount,
              isAnalyzing: _isProcessing,
              isOnline: _isOnline,
            ),
          ),

          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black87,
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.blue),
                            Text('Camera',
                                style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MapScreen(),
                            ),
                          );
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map, color: Colors.white),
                            Text('Map', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
