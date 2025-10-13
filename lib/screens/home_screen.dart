import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_request_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> requests = [];
  final String apiUrl = "http://127.0.0.1:8000/requests";

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          requests = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error fetching requests: $e");
    }
  }

  Future<void> deleteRequest(String id) async {
    try {
      final response = await http.delete(Uri.parse("$apiUrl/$id"));
      if (response.statusCode == 200) {
        if (!mounted) return; // ✅ fix async context warning
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request deleted successfully")),
        );
        fetchRequests();
      }
    } catch (e) {
      debugPrint("Error deleting request: $e");
    }
  }

  Future<void> navigateToEdit(Map<String, dynamic> request) async {
    // ✅ Use mounted check to avoid async context issues
    if (!mounted) return;

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRequestScreen(request: request),
      ),
    );

    if (updated == true && mounted) {
      fetchRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Helper"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: requests.isEmpty
          ? const Center(child: Text("No requests available"))
          : RefreshIndicator(
              onRefresh: fetchRequests,
              child: ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(request['title']),
                      subtitle: Text(request['description']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => navigateToEdit(request),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteRequest(request['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
