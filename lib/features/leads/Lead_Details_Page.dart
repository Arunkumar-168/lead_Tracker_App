import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracker_app/features/leads/Controller/Lead_Details_Controller.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadDetailPage extends StatelessWidget {
  final String leadId;
  final LeadDetailController controller = Get.put(LeadDetailController());

  LeadDetailPage({super.key, required this.leadId}) {
    controller.loadLead(leadId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lead Detail')),
      body: GetBuilder<LeadDetailController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.lead == null) {
            return const Center(child: Text('Lead not found'));
          }
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(controller.lead!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.lead!.company),
                      if (controller.lead!.phone != null)
                        Text("Phone: ${controller.lead!.phone}"),
                      if (controller.lead!.status.isNotEmpty)
                        Text("Status: ${controller.lead!.status}"),
                    ],
                  ),
                  trailing: controller.lead!.attachmentUrl != null
                      ? IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {
                      // Open attachment URL
                      launchUrl(Uri.parse(controller.lead!.attachmentUrl!));
                    },
                  )
                      : null,
                ),
              ),
              // Notes List
              Expanded(
                child: controller.notes.isEmpty
                    ? const Center(child: Text('No notes yet'))
                    : ListView.builder(
                  itemCount: controller.notes.length,
                  itemBuilder: (context, index) {
                    final note = controller.notes[index];
                    return ListTile(
                      title: Text(note.text),
                      subtitle: Text(
                        note.createdAt.toDate().toString(),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),

              // Add Note TextField
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.noteController,
                        decoration: const InputDecoration(
                          hintText: 'Add note',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.noteController.text.trim().isNotEmpty) {
                          controller.addNote();
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
