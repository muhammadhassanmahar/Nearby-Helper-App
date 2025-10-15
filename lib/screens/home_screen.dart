import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_request_screen.dart';
import 'requests_list_screen.dart';
import 'request_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> requests = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  // ✅ Fetch all requests
  Future<void> fetchRequests() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getRequests();
      if (!mounted) return;
      setState(() {
        requests = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load requests: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ✅ Add Comment function (fixed)
  Future<void> addCommentDialog(String requestId) async {
    final TextEditingController authorController = TextEditingController();
    final TextEditingController commentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: authorController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
              ),
            ),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Comment',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final author = authorController.text.trim();
              final message = commentController.text.trim();
              if (author.isEmpty || message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              try {
                await ApiService.postComment(
                  requestId: requestId,
                  author: author,
                  message: message,
                );

                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Comment added successfully')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Failed to add comment: $e')),
                );
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  // ✅ Simple local "getRequestById" helper (fix for missing method)
  Map<String, dynamic>? getRequestById(String id) {
    try {
      return requests.firstWhere((req) => req['id'] == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Helper"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchRequests,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(child: Text('No requests found'))
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        title: Text(request['title'] ?? 'No title'),
                        subtitle: Text(request['description'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.comment, color: Colors.teal),
                          onPressed: () =>
                              addCommentDialog(request['id'].toString()),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RequestDetailScreen(
                                request: request,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRequestScreen()),
          );
        },
        label: const Text('Add Request'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.teal.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.teal),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.list, color: Colors.teal),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RequestsListScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
