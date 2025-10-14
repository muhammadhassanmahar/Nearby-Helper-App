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

  /// 🗑️ Delete request from backend (safe context handling)
  Future<void> deleteRequest() async {
    final ctx = context; // Save current context safely
    try {
      final response =
          await http.delete(Uri.parse("$apiUrl/${widget.request['id']}"));

      if (!mounted || !ctx.mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text("✅ Request deleted successfully")),
        );
        Navigator.pop(ctx, true);
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text("❌ Failed to delete (Error ${response.statusCode})"),
          ),
        );
      }
    } catch (e) {
      if (!mounted || !ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
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

                // ✅ Show phone number only if provided
                if (request['phone'] != null &&
                    request['phone'].toString().trim().isNotEmpty)
                  infoTile("Phone", request['phone']),

                infoTile("Status",
                    request['status']?.toString().toUpperCase() ?? "Pending"),

                const Spacer(),

                // 🧭 Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final ctx = context; // Safe context reference
                          final updated = await Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditRequestScreen(request: request),
                            ),
                          );

                          if (!mounted || !ctx.mounted) return;
                          if (updated == true) Navigator.pop(ctx, true);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.withValues(alpha: 0.9),
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
                          backgroundColor: Colors.red.withValues(alpha: 0.9),
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

  /// 📋 Reusable info tile widget
  Widget infoTile(String label, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
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
