import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<Map<String, String>> uploadFile(String userId, File file) async {
    if (!file.existsSync()) {
      throw Exception("File not found: ${file.path}");
    }
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = _storage.ref().child('lead_attachments/$userId/$fileName');

    try {
      final task = await ref.putFile(file);
      final url = await task.ref.getDownloadURL();
      return {'url': url, 'name': fileName};
    } on FirebaseException catch (e) {
      // Handle Storage-specific errors
      throw Exception("Upload failed: ${e.message}");
    }
  }

  /// Delete a file safely
  Future<void> deleteFile(String userId, String fileName) async {
    final ref = _storage.ref().child('lead_attachments/$userId/$fileName');
    try {
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        print('File not found, skipping delete');
      } else {
        rethrow;
      }
    }
  }
}


class LeadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();
  Future<void> saveLead({
    String? id,
    required String name,
    required String company,
    String? email,
    String? phone,
    required String status,
    File? attachment,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw 'User not logged in';

    final docRef = id != null
        ? _firestore.collection('leads').doc(id)
        : _firestore.collection('leads').doc();

    String? attachmentUrl;
    String? attachmentName;

    if (attachment != null) {
      final upload = await _storageService.uploadFile(uid, attachment);
      attachmentUrl = upload['url'];
      attachmentName = upload['name'];
    }

    await docRef.set({
      'name': name,
      'company': company,
      'email': email,
      'phone': phone,
      'status': status,
      'attachmentUrl': attachmentUrl,
      'attachmentName': attachmentName,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
