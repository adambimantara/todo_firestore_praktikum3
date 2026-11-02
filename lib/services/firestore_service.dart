import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirestoreService._internal();

  // Helper getter for current user's UID
  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'Pengguna belum terautentikasi. Silakan masuk terlebih dahulu.';
    }
    return user.uid;
  }

  // Reference to user's isolated tasks subcollection: users/{uid}/tasks
  CollectionReference<Map<String, dynamic>> _userTasksRef() {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('tasks');
  }

  // Real-time Stream of tasks ordered by timestamp descending
  Stream<List<Task>> getTasks() {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Stream.value([]);
      }

      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      });
    } catch (e) {
      // Fallback stream on error
      return Stream.error('Gagal memuat tugas dari Firestore: $e');
    }
  }

  // Add Task to users/{uid}/tasks
  Future<DocumentReference> addTask(
    String title,
    String description, {
    String category = 'Praktikum',
    String priority = 'Sedang',
  }) async {
    try {
      return await _userTasksRef().add({
        'title': title.trim(),
        'description': description.trim(),
        'isDone': false,
        'category': category,
        'priority': priority,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Gagal menambahkan tugas: $e';
    }
  }

  // Update Task details
  Future<void> updateTask(
    String id,
    String newTitle,
    String newDescription, {
    String? category,
    String? priority,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'title': newTitle.trim(),
        'description': newDescription.trim(),
      };
      if (category != null) data['category'] = category;
      if (priority != null) data['priority'] = priority;

      await _userTasksRef().doc(id).update(data);
    } catch (e) {
      throw 'Gagal memperbarui tugas: $e';
    }
  }

  // Toggle Task isDone status
  Future<void> toggleDone(String id, bool currentStatus) async {
    try {
      await _userTasksRef().doc(id).update({
        'isDone': !currentStatus,
      });
    } catch (e) {
      throw 'Gagal mengubah status tugas: $e';
    }
  }

  // Delete Task from Firestore
  Future<void> deleteTask(String id) async {
    try {
      await _userTasksRef().doc(id).delete();
    } catch (e) {
      throw 'Gagal menghapus tugas: $e';
    }
  }
}
