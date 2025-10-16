import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_request_screen.dart';
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

  // ✅ Show Comments + Add Comment dialog safely
  Future<void> showCommentsAndAddDialog(String requestId) async {
    final TextEditingController authorController = TextEditingController();
    final TextEditingController commentController = TextEditingController();

    final request = requests.firstWhere(
      (r) => r['id'].toString() == requestId,
      orElse: () => null,
    );

    final List<dynamic> comments = request?['comments'] ?? [];

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Comments'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Show existing comments
                    if (comments.isNotEmpty)
                      Column(
                        children: comments.map((c) {
                          return ListTile(
                            leading:
                                const Icon(Icons.person, color: Colors.teal),
                            title: Text(
                              c['author'] ?? 'Anonymous',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(c['message'] ?? ''),
                          );
                        }).toList(),
                      )
                    else
                      const Text(
                        "No comments yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    const Divider(),
                    const SizedBox(height: 10),

                    // 🔹 Add new comment
                    TextField(
                      controller: authorController,
                      decoration:
                          const InputDecoration(labelText: 'Your Name'),
                    ),
                    TextField(
                      controller: commentController,
                      decoration:
                          const InputDecoration(labelText: 'Add a comment'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                  },
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final author = authorController.text.trim();
                    final message = commentController.text.trim();

                    if (author.isEmpty || message.isEmpty) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill all fields')),
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

                      // ✅ Update in main list
                      setState(() {
                        final index = requests.indexWhere(
                            (r) => r['id'].toString() == requestId);
                        if (index != -1) {
                          requests[index]['comments'] ??= [];
                          requests[index]['comments'].add({
                            'author': author,
                            'message': message,
                          });
                        }
                      });

                      if (ctx.mounted) {
                        // ✅ Update inside dialog UI
                        setDialogState(() {
                          comments.add({
                            'author': author,
                            'message': message,
                          });
                          authorController.clear();
                          commentController.clear();
                        });

                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                              content: Text('✅ Comment added successfully')),
                        );
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                              content: Text('❌ Failed to add comment: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Post'),
                ),
              ],
            );
          },
        );
      },
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
                                onPressed: () => showCommentsAndAddDialog(
                                  request['id'].toString(),
                                ),
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
          fetchRequests(); // ✅ Safe refresh
        },
        label: const Text('Add Request'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
