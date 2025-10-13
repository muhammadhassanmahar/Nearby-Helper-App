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

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Request updated successfully")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Failed to update (Error: ${response.statusCode})",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Edit Request"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF43C6AC), Color(0xFF191654)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Form with Glass Effect
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Edit Help Request",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: nameController,
                          label: "Your Name",
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 15),

                        _buildTextField(
                          controller: titleController,
                          label: "Request Title",
                          icon: Icons.title_outlined,
                        ),
                        const SizedBox(height: 15),

                        _buildTextField(
                          controller: descriptionController,
                          label: "Description",
                          icon: Icons.description_outlined,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 15),

                        _buildTextField(
                          controller: locationController,
                          label: "Location",
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 20),

                        // Status Dropdown
                        DropdownButtonFormField<String>(
                          value: status,
                          dropdownColor: Colors.black54,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Status",
                            labelStyle:
                                const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: "pending", child: Text("Pending")),
                            DropdownMenuItem(
                                value: "in_progress",
                                child: Text("In Progress")),
                            DropdownMenuItem(
                                value: "completed", child: Text("Completed")),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => status = val);
                          },
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: updateRequest,
                            icon: const Icon(Icons.save),
                            label: const Text(
                              "Update Request",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              foregroundColor: Colors.teal.shade900,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
