import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String text;
  final Timestamp createdAt;

  NoteModel({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'createdAt': createdAt,
  };

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
