import 'package:cloud_firestore/cloud_firestore.dart';

class LeadListModel {
  final String id;
  final String name;
  final String company;
  final String? email;
  final String? phone;
  final String status; // New | InProgress | Closed
  final String? attachmentUrl;
  final String? attachmentName;
  final Timestamp createdAt;
  final String ownerId;

  LeadListModel({
    required this.id,
    required this.name,
    required this.company,
    this.email,
    this.phone,
    required this.status,
    this.attachmentUrl,
    this.attachmentName,
    required this.createdAt,
    required this.ownerId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'company': company,
    'email': email,
    'phone': phone,
    'status': status,
    'attachmentUrl': attachmentUrl,
    'attachmentName': attachmentName,
    'createdAt': createdAt,
    'ownerId': ownerId,
  };

  factory LeadListModel.fromMap(Map<String, dynamic> map) {
    return LeadListModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      company: map['company'] ?? '',
      email: map['email'],
      phone: map['phone'],
      status: map['status'] ?? 'New',
      attachmentUrl: map['attachmentUrl'],
      attachmentName: map['attachmentName'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      ownerId: map['ownerId'] ?? '',
    );
  }
}
