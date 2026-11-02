import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime timestamp;
  final String category;
  final String priority;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isDone = false,
    DateTime? timestamp,
    this.category = 'Praktikum',
    this.priority = 'Sedang',
  }) : timestamp = timestamp ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? timestamp,
    String? category,
    String? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }

  // Convert Task to Map for Cloud Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'timestamp': Timestamp.fromDate(timestamp),
      'category': category,
      'priority': priority,
    };
  }

  // Factory to create Task from Firestore Document Snapshot Map
  factory Task.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate = DateTime.now();
    final rawTimestamp = map['timestamp'];

    if (rawTimestamp != null) {
      if (rawTimestamp is Timestamp) {
        parsedDate = rawTimestamp.toDate();
      } else if (rawTimestamp is int) {
        parsedDate = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
      } else if (rawTimestamp is DateTime) {
        parsedDate = rawTimestamp;
      } else if (rawTimestamp is String) {
        parsedDate = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
      }
    }

    return Task(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      isDone: map['isDone'] as bool? ?? false,
      timestamp: parsedDate,
      category: map['category'] as String? ?? 'Praktikum',
      priority: map['priority'] as String? ?? 'Sedang',
    );
  }

  // Helper factory from Firestore DocumentSnapshot
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Task.fromMap(data, doc.id);
  }
}
