import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracker_app/features/leads/Controller/Lead_List_Controller.dart';
import 'package:tracker_app/features/leads/LeadList_Edit_Page.dart';
import 'package:tracker_app/features/leads/Profile_Page.dart';


class LeadPage extends StatelessWidget {
  LeadPage({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          'Lead List',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Get.to(() => const ProfilePage()),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Get.to(() => const LeadListEditPage()),
          ),
        ],
      ),
      body: GetBuilder<LeadListController>(
        init: LeadListController(), // creates controller instance
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: searchController,
                  onChanged: controller.applySearch,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: "Search leads",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.purple, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.purple, width: 1),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: controller.searchList.isEmpty
                    ? const Center(child: Text('No leads found'))
                    : ListView.builder(
                  itemCount: controller.searchList.length,
                  itemBuilder: (context, index) {
                    final lead = controller.searchList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lead.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.bottomSheet(
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        child: Wrap(
                                          children: [
                                            ListTile(
                                              leading: const Icon(Icons.edit, color: Colors.purple),
                                              title: const Text('Edit Lead'),
                                              onTap: () {
                                                Get.back();
                                                Get.to(() => LeadListEditPage(
                                                  lead: controller.searchList[index].toMap(),
                                                ));
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.delete, color: Colors.red),
                                              title: const Text('Delete Lead'),
                                              onTap: () {
                                                Get.back();
                                                Get.defaultDialog(
                                                  title: 'Confirm Delete',
                                                  middleText: 'Are you sure you want to delete this lead?',
                                                  textConfirm: 'Yes',
                                                  textCancel: 'No',
                                                  confirmTextColor: Colors.white,
                                                  onConfirm: () async {
                                                    await controller.deleteLead(
                                                        controller.searchList[index].id);
                                                    Get.back();
                                                    Get.snackbar(
                                                      'Deleted',
                                                      'Lead deleted successfully',
                                                      snackPosition: SnackPosition.BOTTOM,
                                                      backgroundColor: Colors.green,
                                                      colorText: Colors.white,
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.close),
                                              title: const Text('Cancel'),
                                              onTap: () => Get.back(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.more_vert,
                                    color: lead.status == 'New'
                                        ? Colors.green
                                        : lead.status == 'Contacted'
                                        ? Colors.orange
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("Company: ${lead.company}", style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 2),
                            Text("Phone: ${lead.phone ?? 'N/A'}", style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 2),
                            Text("Status: ${lead.status}", style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
