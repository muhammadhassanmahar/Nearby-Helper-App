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
  Set<String> expandedRequests = {}; // ✅ Track which requests have comments shown

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getRequests();
      if (!mounted) return; // ✅ Safe check
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

  Future<void> addComment(String requestId, String author, String message) async {
    try {
      await ApiService.postComment(
        requestId: requestId,
        author: author,
        message: message,
      );

      if (!mounted) return;

      setState(() {
        final index = requests.indexWhere((r) => r['id'].toString() == requestId);
        if (index != -1) {
          requests[index]['comments'] ??= [];
          requests[index]['comments'].add({
            'author': author,
            'message': message,
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Comment added successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to add comment: $e')),
      );
    }
  }

  /// 🧍‍♂️ Generate or load avatar for user
  Widget buildAvatar(String? avatarUrl, String? name) {
    final displayName = (name ?? "User").split(" ").take(2).join(" ");
    final avatarLink = avatarUrl != null && avatarUrl.isNotEmpty
        ? avatarUrl
        : "https://ui-avatars.com/api/?name=$displayName&background=009688&color=fff&bold=true";

    return CircleAvatar(
      radius: 25,
      backgroundImage: NetworkImage(avatarLink),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget buildCommentsSection(Map<String, dynamic> request) {
    final TextEditingController authorController = TextEditingController();
    final TextEditingController commentController = TextEditingController();
    final List<dynamic> comments = request['comments'] ?? [];

    return Column(
      children: [
        const Divider(),
        if (comments.isNotEmpty)
          Column(
            children: comments.map((c) {
              return ListTile(
                leading: buildAvatar(null, c['author'] ?? 'A'), // ✅ auto avatar for commenter
                title: Text(
                  c['author'] ?? 'Anonymous',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(c['message'] ?? ''),
              );
            }).toList(),
          )
        else
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No comments yet.', style: TextStyle(color: Colors.grey)),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: [
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Your Name'),
              ),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: 'Add a comment'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final author = authorController.text.trim();
                  final message = commentController.text.trim();
                  if (author.isEmpty || message.isEmpty) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  await addComment(request['id'].toString(), author, message);
                  if (!mounted) return;

                  authorController.clear();
                  commentController.clear();
                },
                icon: const Icon(Icons.send),
                label: const Text('Post Comment'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
            ],
          ),
        ),
      ],
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchRequests),
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
                    final requestId = request['id'].toString();
                    final isExpanded = expandedRequests.contains(requestId);
                    final name = request['name'] ?? request['title'] ?? 'Anonymous';
                    final avatarUrl = request['avatar'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: buildAvatar(avatarUrl, name), // ✅ Avatar added
                              title: Text(
                                request['title'] ?? 'No title',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(request['description'] ?? ''),
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
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    if (isExpanded) {
                                      expandedRequests.remove(requestId);
                                    } else {
                                      expandedRequests.add(requestId);
                                    }
                                  });
                                },
                                icon: Icon(
                                  isExpanded ? Icons.expand_less : Icons.comment,
                                  color: Colors.teal,
                                ),
                                label: Text(
                                  isExpanded ? 'Hide Comments' : 'View Comments',
                                  style: const TextStyle(color: Colors.teal),
                                ),
                              ),
                            ),
                            if (isExpanded) buildCommentsSection(request),
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
          fetchRequests();
        },
        label: const Text('Add Request'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
