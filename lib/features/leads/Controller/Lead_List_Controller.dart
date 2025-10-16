import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:tracker_app/features/leads/Model/Lead_List_Model.dart';

class LeadListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<LeadListModel> list = [];
  List<LeadListModel> searchList = [];
  bool isLoading = false;

  StreamSubscription<QuerySnapshot>? _listener;
  Timer? _searchDebounce;

  String? get _uid => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    fetchLeads();
  }

  @override
  void onClose() {
    _listener?.cancel();
    _searchDebounce?.cancel();
    super.onClose();
  }

  void fetchLeads() {
    if (_uid == null) return;
    isLoading = true;
    update();
    _listener = _firestore
        .collection('leads')
        .where('ownerId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      list = snapshot.docs.map((doc) => LeadListModel.fromMap(doc.data())).toList();
      searchList = List.from(list);
      isLoading = false;
      update();
    }, onError: (err) {
      isLoading = false;
      update();
      Get.snackbar('Error', 'Failed to fetch leads: $err', snackPosition: SnackPosition.BOTTOM);
    });
  }

  void applySearch(String query) {
    if (query.isEmpty) {
      searchList = List.from(list); // reset to full list
    } else {
      final q = query.toLowerCase();
      searchList = list.where((lead) {
        return lead.name.toLowerCase().contains(q) ||
            lead.company.toLowerCase().contains(q) ||
            (lead.email ?? '').toLowerCase().contains(q) ||
            (lead.phone ?? '').toLowerCase().contains(q);
      }).toList();
    }
    update(); // refresh the UI
  }



  Future<Map<String, String>> uploadAttachment(File file) async {
    if (!file.existsSync()) {
      throw Exception("File not found at: ${file.path}");
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not authenticated");

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('lead_attachments/$uid/$fileName');

      // Start upload
      final UploadTask uploadTask = storageRef.putFile(file);

      // Wait until upload completes
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      // Get download URL
      final String url = await snapshot.ref.getDownloadURL();

      return {
        'url': url,
        'name': fileName,
      };
    } on FirebaseException catch (e) {
      print("Firebase Storage error: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("Unknown error: $e");
      rethrow;
    }
  }

  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null) return null;
    return File(path);
  }
  Future<void> saveLead({
    String? id,
    required String name,
    required String company,
    String? email,
    String? phone,
    required String status,
    File? attachment,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User not authenticated");

    final col = FirebaseFirestore.instance.collection('leads');

    String? attachmentUrl;
    String? attachmentName;

    if (attachment != null) {
      final upload = await uploadAttachment(attachment);
      attachmentUrl = upload['url'];
      attachmentName = upload['name'];
    }

    final leadData = {
      'name': name,
      'company': company,
      'email': email ?? '',
      'phone': phone ?? '',
      'status': status,
      'attachmentUrl': attachmentUrl ?? '',
      'attachmentName': attachmentName ?? '',
      'ownerId': uid,
      'createdAt': Timestamp.now(),
    };

    if (id != null) {
      await col.doc(id).update(leadData);
    } else {
      await col.doc().set(leadData);
    }
  }

  Future<void> deleteLead(String? id) async {
    if (id == null || id.isEmpty) {
      print('Invalid ID: cannot delete');
      return;
    }

    final docRef = _firestore.collection('leads').doc(id);
    final docSnap = await docRef.get();
    if (!docSnap.exists) return;

    final data = docSnap.data() as Map<String, dynamic>;
    final attachmentName = data['attachmentName'];

    // delete attachment if exists
    if (attachmentName != null && attachmentName.isNotEmpty) {
      try {
        await _storage.ref().child('lead_attachments').child(_uid!).child(attachmentName).delete();
      } catch (e) {
        if (!e.toString().contains('object-not-found')) rethrow;
      }
    }
    await docRef.delete();
  }

}