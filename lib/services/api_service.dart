import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // 🌐 Dynamically determine base URL
  static String get baseUrl {
    String url;

    if (kIsWeb) {
      url = "http://localhost:8000"; // ✅ For web browser
    } else if (Platform.isAndroid) {
      url = "http://10.0.2.2:8000"; // ✅ For Android emulator
    } else {
      url = "http://127.0.0.1:8000"; // ✅ For Windows, macOS, iOS
    }

    // 👇 Print the chosen base URL for debugging
    debugPrint("🌍 Using base URL: $url");
    return url;
  }

  // ✅ Get all help requests
  static Future<List<dynamic>> getRequests() async {
    final response = await http.get(Uri.parse('$baseUrl/requests'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('❌ Failed to load requests');
    }
  }

  // ✅ Add a new help request
  static Future<void> addRequest(Map<String, dynamic> requestData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/requests'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('❌ Failed to add request');
    }
  }

  // ✅ Update an existing request
  static Future<void> updateRequest(String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/requests/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode != 200) {
      throw Exception('❌ Failed to update request');
    }
  }

  // ✅ Delete a request
  static Future<void> deleteRequest(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/requests/$id'));

    if (response.statusCode != 200) {
      throw Exception('❌ Failed to delete request');
    }
  }

  // ✅ Add a comment to a request
  static Future<void> postComment({
    required String requestId,
    required String author,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/requests/$requestId/comments'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "author": author,
        "message": message,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('❌ Failed to add comment');
    }
  }

  // ✅ Get all comments for a specific request
  static Future<List<dynamic>> getComments(String requestId) async {
    final response = await http.get(Uri.parse('$baseUrl/requests/$requestId/comments'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('❌ Failed to load comments');
    }
  }
}
