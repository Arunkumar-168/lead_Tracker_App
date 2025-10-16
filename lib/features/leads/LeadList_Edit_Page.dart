import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracker_app/features/auth/Validator.dart';
import 'package:tracker_app/features/leads/Controller/Lead_List_Controller.dart';
import 'Lead_Page.dart';

class LeadListEditPage extends StatefulWidget {
  final Map<String, dynamic>? lead; // nullable for new lead

  const LeadListEditPage({super.key, this.lead});

  @override
  State<LeadListEditPage> createState() => _LeadListEditPageState();
}

class _LeadListEditPageState extends State<LeadListEditPage> {
  final controller = Get.find<LeadListController>();
  final formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController companyController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  String status = 'New';
  File? attachment;

  final List<String> statusOptions = ['New', 'InProgress', 'Closed'];

  @override
  void initState() {
    super.initState();
    final lead = widget.lead;
    nameController = TextEditingController(text: lead?['name'] ?? '');
    companyController = TextEditingController(text: lead?['company'] ?? '');
    emailController = TextEditingController(text: lead?['email'] ?? '');
    phoneController = TextEditingController(text: lead?['phone'] ?? '');
    status = lead?['status'] ?? 'New';
  }

  @override
  void dispose() {
    nameController.dispose();
    companyController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.lead != null && widget.lead!['id'] != null;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.purple,
        title: Text(isEdit ? 'Edit Lead' : 'New Lead',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            )),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    isEdit ? 'Edit Lead Details' : 'Add New Lead',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                const Text('Name',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Enter your name";
                    return Validator.validateName(name: value);
                  },
                  decoration: _inputDecoration("Name"),
                ),
                const SizedBox(height: 15),

                // Company
                const Text('Company',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                TextFormField(
                  controller: companyController,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Enter company name";
                    return Validator.validateCompany(company: value);
                  },
                  decoration: _inputDecoration("Company"),
                ),
                const SizedBox(height: 15),

                // Email
                const Text('Email',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter email";
                    return Validator.validateEmail(email: value);
                  },
                  decoration: _inputDecoration("Email"),
                ),
                const SizedBox(height: 15),

                // Phone
                const Text('Phone',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                TextFormField(
                  controller: phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Enter phone number";
                    return Validator.validatePhone(phone: value);
                  },
                  decoration: _inputDecoration("Phone"),
                ),
                const SizedBox(height: 15),

                // Status Dropdown
                const Text('Status',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  value: status,
                  items: statusOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => status = value);
                  },
                  decoration: _inputDecoration("Select Status"),
                ),
                const SizedBox(height: 20),

                // File Attachment
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    attachment = await controller.pickFile();
                    setState(() {});
                  },
                  icon: const Icon(Icons.attach_file, color: Colors.white),
                  label: Text(
                    attachment != null
                        ? "File: ${attachment!.path.split('/').last}"
                        : "Attach file",
                  ),
                ),
                const SizedBox(height: 25),

                // Save Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      // Print debug info
                      print('--- Lead Data ---');
                      print('Name: ${nameController.text}');
                      print('Company: ${companyController.text}');
                      print('Email: ${emailController.text}');
                      print('Phone: ${phoneController.text}');
                      print('Status: $status');
                      print(
                          'Attachment: ${attachment?.path ?? "No attachment"}');
                      print('Is Edit: $isEdit');
                      print('Lead ID: ${widget.lead?['id'] ?? "New Lead"}');

                      try {
                        if (isEdit && (widget.lead!['id'] ?? '').isNotEmpty) {
                          await controller.saveLead(
                            id: widget.lead!['id'],
                            name: nameController.text,
                            company: companyController.text,
                            email: emailController.text,
                            phone: phoneController.text,
                            status: status,
                            attachment: attachment,
                          );
                          Get.snackbar(
                            'Success',
                            'Lead updated successfully',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green.shade600,
                            colorText: Colors.white,
                          );
                        } else {
                          await controller.saveLead(
                            name: nameController.text,
                            company: companyController.text,
                            email: emailController.text,
                            phone: phoneController.text,
                            status: status,
                            attachment: attachment,
                          );
                          Get.snackbar(
                            'Success',
                            'New lead created successfully',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green.shade600,
                            colorText: Colors.white,
                          );
                        }
                        Get.offAll(() => LeadPage());
                      } catch (e) {
                        print('Error saving lead: $e'); // Print error
                        Get.snackbar(
                          'Error',
                          'Failed to save lead: $e',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.shade600,
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: Text(isEdit ? "Save Changes" : "Add Lead"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.purple, width: 1.5),
      ),
    );
  }
}
