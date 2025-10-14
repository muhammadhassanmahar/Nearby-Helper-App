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
  LatLng? _selectedLocation;
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

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _selectedLocation = _currentLocation;
      _loading = false;
    });

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
        title: const Text("Select Location"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : _currentLocation == null
              ? const Center(
                  child: Text("Unable to get location 😕"),
                )
              : GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onTap: (LatLng tappedPoint) {
                    setState(() => _selectedLocation = tappedPoint);
                  },
                  markers: {
                    if (_selectedLocation != null)
                      Marker(
                        markerId: const MarkerId('selected_location'),
                        position: _selectedLocation!,
                        infoWindow:
                            const InfoWindow(title: "Selected Location"),
                      ),
                  },
                ),
      floatingActionButton: _selectedLocation == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.pop(context, _selectedLocation);
              },
              icon: const Icon(Icons.check),
              label: const Text("Confirm"),
              backgroundColor: Colors.green,
            ),
    );
  }
}
