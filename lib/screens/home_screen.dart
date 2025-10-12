import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();

  List<dynamic> locations = [];

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    try {
      final data = await ApiService.getLocations();
      setState(() {
        locations = data;
      });
    } catch (e) {
      debugPrint("Error fetching: $e");
    }
  }

  Future<void> addLocation() async {
    final name = nameController.text.trim();
    final lat = double.tryParse(latController.text);
    final lng = double.tryParse(lngController.text);

    if (name.isEmpty || lat == null || lng == null) return;

    await ApiService.saveLocation(name, lat, lng);
    nameController.clear();
    latController.clear();
    lngController.clear();
    fetchLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Helper')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Place Name'),
            ),
            TextField(
              controller: latController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: lngController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addLocation,
              child: const Text('Save Location'),
            ),
            const Divider(height: 30),
            const Text('Saved Locations', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final loc = locations[index];
                  return ListTile(
                    title: Text(loc['name']),
                    subtitle: Text("Lat: ${loc['latitude']} | Lng: ${loc['longitude']}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
