import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class NearbyMapScreen extends StatefulWidget {
  const NearbyMapScreen({super.key});

  @override
  State<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends State<NearbyMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LocationData? _currentLocation;
  final Location _locationService = Location();

  final Set<Marker> _markers = {
    Marker(
      markerId: const MarkerId('help_request_1'),
      position: const LatLng(24.8607, 67.0011), // Example: Karachi
      infoWindow: const InfoWindow(
        title: 'Need groceries delivered',
        snippet: 'Gulshan-e-Iqbal, Karachi',
      ),
    ),
    Marker(
      markerId: const MarkerId('help_request_2'),
      position: const LatLng(31.5204, 74.3587), // Example: Lahore
      infoWindow: const InfoWindow(
        title: 'Looking for medical aid',
        snippet: 'Model Town, Lahore',
      ),
    ),
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final locationData = await _locationService.getLocation();
    setState(() {
      _currentLocation = locationData;
    });
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentLocation == null) return;
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      14,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Requests'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Refresh markers or reload from API
            },
          ),
        ],
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentLocation!.latitude!,
                  _currentLocation!.longitude!,
                ),
                zoom: 13,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'locate_me',
            backgroundColor: Colors.teal,
            onPressed: _goToCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'list_view',
            backgroundColor: Colors.orange,
            onPressed: () {
              Navigator.pushNamed(context, '/requests-list');
            },
            child: const Icon(Icons.list),
          ),
        ],
      ),
    );
  }
}
