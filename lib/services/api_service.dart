import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000"; // FastAPI base

  static Future<List<dynamic>> getLocations() async {
    final response = await http.get(Uri.parse('$baseUrl/get-locations'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load locations');
    }
  }

  static Future<void> saveLocation(String name, double lat, double lng) async {
    final response = await http.post(
      Uri.parse('$baseUrl/save-location'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "latitude": lat,
        "longitude": lng,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save location');
    }
  }
}
