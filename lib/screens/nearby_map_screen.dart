import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class NearbyMapScreen extends StatefulWidget {
  const NearbyMapScreen({super.key});

  @override
  State<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends State<NearbyMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  /// Request permission & get current location
  Future<void> _determinePosition() async {
    setState(() => _loading = true);

    var status = await Permission.location.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied ❌")),
      );
      setState(() => _loading = false);
      return;
    }

    // ✅ New method: use LocationSettings instead of deprecated desiredAccuracy
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _loading = false;
    });

    // ✅ Use the map controller to move camera
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Map"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : _currentLocation == null
              ? const Center(
                  child: Text(
                    "Unable to get location 😕",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: {
                    Marker(
                      markerId: const MarkerId('current_location'),
                      position: _currentLocation!,
                      infoWindow: const InfoWindow(title: "You are here"),
                    ),
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _determinePosition,
        icon: const Icon(Icons.my_location),
        label: const Text("Refresh"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
