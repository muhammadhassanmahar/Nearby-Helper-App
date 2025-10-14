import 'package:flutter/material.dart';
import 'package:nearby_helper_app/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<dynamic> requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  /// ✅ Fetch all requests from API safely
  Future<void> fetchRequests() async {
    try {
      final data = await ApiService.getRequests();

      if (!mounted) return; // Prevent context use after async gap
      setState(() {
        requests = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading requests: ${e.toString()}")),
        );
      }
    }
  }

  /// ✅ Delete a specific request safely
  Future<void> deleteRequest(String id) async {
    try {
      await ApiService.deleteRequest(id);
      if (!mounted) return;

      await fetchRequests();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request deleted successfully")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      /// ✅ AppBar
      appBar: AppBar(
        title: const Text(
          "Nearby Helper",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),

      /// ✅ Floating Add Request Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        onPressed: () => Navigator.pushNamed(context, '/add-request'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Request",
          style: TextStyle(color: Colors.white),
        ),
      ),

      /// ✅ Body
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            )
          : RefreshIndicator(
              onRefresh: fetchRequests,
              child: requests.isEmpty
                  ? const Center(
                      child: Text(
                        "No help requests found.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final req = requests[index];
                        final name = req['name'] ?? 'Unknown';
                        final desc =
                            req['description'] ?? 'No description provided';
                        final location =
                            req['location'] ?? 'Location not provided';
                        final date = req['createdAt'] != null
                            ? DateTime.tryParse(req['createdAt'] ?? '')
                                    ?.toLocal()
                                    .toString()
                                    .split(' ')
                                    .first ??
                                ''
                            : '';

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.teal.shade300,
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    desc,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 16, color: Colors.teal),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          location,
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (date.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        "Date: $date",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () =>
                                  deleteRequest(req['id'].toString()),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/request-detail',
                                arguments: req,
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
