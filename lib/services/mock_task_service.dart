import 'dart:async';
import '../models/task.dart';

class MockTaskService {
  static final MockTaskService _instance = MockTaskService._internal();
  factory MockTaskService() => _instance;

  final List<Task> _tasks = [];
  final StreamController<List<Task>> _taskStreamController =
      StreamController<List<Task>>.broadcast();

  MockTaskService._internal() {
    _initDummyData();
  }

  void _initDummyData() {
    final now = DateTime.now();
    _tasks.addAll([
      Task(
        id: '1',
        title: 'Pelajari Arsitektur Cloud Firestore',
        description: 'Pahami hierarki database NoSQL: Root Collection > Document > Subcollection untuk multi-user.',
        isDone: true,
        category: 'Praktikum',
        priority: 'Tinggi',
        timestamp: now.subtract(const Duration(hours: 4)),
      ),
      Task(
        id: '2',
        title: 'Rancang UI Modern Mobile To-Do List',
        description: 'Gunakan palet warna navy, tipografi Plus Jakarta Sans, dan card glassmorphism responsif.',
        isDone: true,
        category: 'Desain',
        priority: 'Tinggi',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
      ),
      Task(
        id: '3',
        title: 'Mengerjakan Modul Praktikum 3',
        description: 'Selesaikan laporan akademik dan pastikan seluruh fitur CRUD teruji di emulator Android.',
        isDone: false,
        category: 'Kuliah',
        priority: 'Tinggi',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      Task(
        id: '4',
        title: 'Audit Firestore Security Rules',
        description: 'Terapkan rules isolasi data per-user UID untuk menjamin privasi data antar akun.',
        isDone: false,
        category: 'Keamanan',
        priority: 'Sedang',
        timestamp: now.subtract(const Duration(minutes: 25)),
      ),
    ]);
    _notify();
  }

  void _notify() {
    _tasks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _taskStreamController.add(List.unmodifiable(_tasks));
  }

  Stream<List<Task>> getTasks() async* {
    _tasks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    yield List.unmodifiable(_tasks);
    yield* _taskStreamController.stream;
  }

  Future<void> addTask(
    String title,
    String description, {
    String category = 'Praktikum',
    String priority = 'Sedang',
  }) async {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      isDone: false,
      category: category,
      priority: priority,
      timestamp: DateTime.now(),
    );
    _tasks.insert(0, newTask);
    _notify();
  }

  Future<void> updateTask(
    String id,
    String newTitle,
    String newDescription, {
    String? category,
    String? priority,
  }) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        title: newTitle.trim(),
        description: newDescription.trim(),
        category: category ?? _tasks[index].category,
        priority: priority ?? _tasks[index].priority,
      );
      _notify();
    }
  }

  Future<void> toggleDone(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isDone: !_tasks[index].isDone,
      );
      _notify();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    _notify();
  }
}
