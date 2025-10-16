import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracker_app/features/leads/Model/Lead_List_Model.dart';
import 'package:tracker_app/features/leads/Model/Lead_Note_Model.dart';


class LeadDetailController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LeadListModel? lead;
  List<NoteModel> notes = [];
  final noteController = TextEditingController();
  bool isLoading = false;

  String? get _uid => _auth.currentUser?.uid;

  /// Upload a file to Firebase Storage and return its URL and file name
  Future<Map<String, String>> uploadAttachment({
    required String userId,
    required String attachmentPath,
  }) async {
    final File file = File(attachmentPath);

    if (!file.existsSync()) {
      throw Exception("File not found at: $attachmentPath");
    }

    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final Reference storageRef =
    FirebaseStorage.instance.ref().child('leads/$userId/$fileName');

    try {
      // Start upload
      final UploadTask uploadTask = storageRef.putFile(file);

      // Wait for completion
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String url = await snapshot.ref.getDownloadURL();

      return {'url': url, 'name': fileName};
    } on FirebaseException catch (e) {
      print("Storage Error: ${e.code} - ${e.message}");
      rethrow; // Let the caller handle it
    } catch (e) {
      print("Unknown error uploading file: $e");
      rethrow;
    }
  }

  /// Load lead and notes
  void loadLead(String leadId) async {
    if (_uid == null) return;

    isLoading = true;
    update();

    try {
      final doc = await _firestore.collection('leads').doc(leadId).get();
      if (!doc.exists) return;

      lead = LeadListModel.fromMap(doc.data()!);

      final noteSnap = await _firestore
          .collection('leads')
          .doc(leadId)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .get();

      notes = noteSnap.docs.map((d) => NoteModel.fromMap(d.data())).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load lead: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Add note
  void addNote() async {
    if (noteController.text.trim().isEmpty || lead == null) return;

    final text = noteController.text.trim();
    final id = _firestore.collection('leads').doc().id;
    final newNote = NoteModel(
      id: id,
      text: text,
      createdAt: Timestamp.now(),
    );

    notes.insert(0, newNote); // Optimistic update
    noteController.clear();
    update();

    try {
      await _firestore
          .collection('leads')
          .doc(lead!.id)
          .collection('notes')
          .doc(id)
          .set(newNote.toMap());
    } catch (e) {
      notes.removeWhere((n) => n.id == id);
      Get.snackbar('Error', 'Failed to add note: $e',
          snackPosition: SnackPosition.BOTTOM);
      update();
    }
  }
}
