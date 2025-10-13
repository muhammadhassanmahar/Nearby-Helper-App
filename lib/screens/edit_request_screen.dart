import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditRequestScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  const EditRequestScreen({super.key, required this.request});

  @override
  State<EditRequestScreen> createState() => _EditRequestScreenState();
}

class _EditRequestScreenState extends State<EditRequestScreen> {
  late TextEditingController nameController;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  String status = "pending";

  final String apiUrl = "http://127.0.0.1:8000/requests";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.request['name']);
    titleController = TextEditingController(text: widget.request['title']);
    descriptionController =
        TextEditingController(text: widget.request['description']);
    locationController =
        TextEditingController(text: widget.request['location']);
    status = widget.request['status'];
  }

  Future<void> updateRequest() async {
    final updatedData = {
      "id": widget.request['id'],
      "name": nameController.text.trim(),
      "title": titleController.text.trim(),
      "description": descriptionController.text.trim(),
      "location": locationController.text.trim(),
      "status": status,
    };

    try {
      final response = await http.put(
        Uri.parse("$apiUrl/${widget.request['id']}"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request updated successfully ✅")),
        );
        Navigator.pop(context, true); // send success flag to home
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update request ❌ (${response.statusCode})"),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error updating request: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Request"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Request Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "pending", child: Text("Pending")),
                  DropdownMenuItem(value: "in_progress", child: Text("In Progress")),
                  DropdownMenuItem(value: "completed", child: Text("Completed")),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => status = val);
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: updateRequest,
                icon: const Icon(Icons.save),
                label: const Text("Update Request"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
