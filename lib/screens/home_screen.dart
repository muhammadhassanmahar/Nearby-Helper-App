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

  // ✅ Fetch all requests safely
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

  // ✅ Add Comment Dialog safely (fixed context warning)
  Future<void> addCommentDialog(String requestId) async {
    final TextEditingController authorController = TextEditingController();
    final TextEditingController commentController = TextEditingController();

    // Local context captured for dialog
    final dialogContext = context;

    await showDialog(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Comment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Your Name'),
            ),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(labelText: 'Comment'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final author = authorController.text.trim();
              final message = commentController.text.trim();

              if (author.isEmpty || message.isEmpty) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
                return;
              }

              try {
                await ApiService.postComment(
                  requestId: requestId,
                  author: author,
                  message: message,
                );

                if (!mounted) return;

                // ✅ Update locally to show instantly
                setState(() {
                  final index = requests
                      .indexWhere((r) => r['id'].toString() == requestId);
                  if (index != -1) {
                    requests[index]['comments'] ??= [];
                    requests[index]['comments'].add({
                      'author': author,
                      'message': message,
                    });
                  }
                });

                if (ctx.mounted) Navigator.pop(ctx);
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('✅ Comment added successfully')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('❌ Failed to add comment: $e')),
                  );
                }
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
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
                    final comments = request['comments'] ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 Request title + description
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                request['title'] ?? 'No title',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(request['description'] ?? ''),
                              trailing: IconButton(
                                icon: const Icon(Icons.comment,
                                    color: Colors.teal),
                                onPressed: () => addCommentDialog(
                                    request['id'].toString()),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RequestDetailScreen(request: request),
                                  ),
                                );
                              },
                            ),

                            // 🔹 Comments Section
                            if (comments.isNotEmpty) ...[
                              const Divider(),
                              const Text(
                                "Comments:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal),
                              ),
                              const SizedBox(height: 6),
                              ...comments.map((c) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.person,
                                            color: Colors.teal, size: 18),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                c['author'] ?? 'Anonymous',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(c['message'] ?? ''),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ] else
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "No comments yet.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRequestScreen()),
          );
          if (!mounted) return;
          fetchRequests(); // ✅ Refresh safely on return
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
