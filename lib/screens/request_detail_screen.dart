import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'edit_request_screen.dart';

class RequestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  const RequestDetailScreen({super.key, required this.request});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final String apiUrl = "http://127.0.0.1:8000/requests";

  /// 🗑️ Delete request safely with correct context usage
  Future<void> deleteRequest() async {
    try {
      final response =
          await http.delete(Uri.parse("$apiUrl/${widget.request['id']}"));

      if (!mounted) return; // ✅ Ensures widget still exists after await

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Request deleted successfully")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed to delete (Error ${response.statusCode})"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error deleting request: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Details"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    request['title'] ?? request['name'] ?? "Help Request",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🧾 Info tiles
                infoTile("Name", request['name']),
                infoTile("Description", request['description']),
                infoTile("Location", request['location']),

                // ✅ Correct phone number key from backend
                infoTile(
                  "Phone Number",
                  request['phone_number']?.toString().isNotEmpty == true
                      ? request['phone_number']
                      : "Not provided",
                ),

                infoTile(
                  "Status",
                  request['status']?.toString().toUpperCase() ?? "PENDING",
                ),

                const Spacer(),

                // 🧭 Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _navigateToEditScreen(request);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.teal.withValues(alpha: 0.9), // ✅ fixed
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: deleteRequest,
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red.withValues(alpha: 0.9), // ✅ fixed
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Safe navigation method
  Future<void> _navigateToEditScreen(Map<String, dynamic> request) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRequestScreen(request: request),
      ),
    );

    if (!mounted) return;
    if (updated == true) {
      Navigator.pop(context, true);
    }
  }

  /// 📋 Reusable info tile widget
  Widget infoTile(String label, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08), // ✅ fixed
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
