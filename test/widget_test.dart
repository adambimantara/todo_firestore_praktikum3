import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_firestore/models/task.dart';
import 'package:todo_firestore/pages/login_page.dart';
import 'package:todo_firestore/theme/app_theme.dart';

void main() {
  testWidgets('App smoke test: Renders LoginPage UI correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    ));
    await tester.pumpAndSettle();

    // Verify LoginPage is shown as entry point
    expect(find.text('To-Do List'), findsOneWidget);
    expect(find.text('Welcome Back! Masuk untuk mulai mengelola tugas harian Anda.'), findsOneWidget);
    expect(find.text('Email Mahasiswa'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
    expect(find.text('Isi Akun Demo Praktikum'), findsOneWidget);
    expect(find.text('Daftar Sekarang'), findsOneWidget);
  });

  test('Task model: serialization and copyWith test', () {
    final now = DateTime.now();
    final task = Task(
      id: 'test_1',
      title: 'Belajar Firestore',
      description: 'Pahami Security Rules',
      isDone: false,
      timestamp: now,
      category: 'Praktikum',
      priority: 'Tinggi',
    );

    // Verify fields
    expect(task.id, 'test_1');
    expect(task.title, 'Belajar Firestore');
    expect(task.isDone, false);
    expect(task.category, 'Praktikum');
    expect(task.priority, 'Tinggi');

    // Test copyWith
    final updated = task.copyWith(isDone: true, priority: 'Rendah');
    expect(updated.isDone, true);
    expect(updated.priority, 'Rendah');
    expect(updated.title, 'Belajar Firestore');

    // Test toMap
    final map = task.toMap();
    expect(map['title'], 'Belajar Firestore');
    expect(map['isDone'], false);
    expect(map['category'], 'Praktikum');

    // Test fromMap
    final reconstructed = Task.fromMap(map, 'test_1');
    expect(reconstructed.id, 'test_1');
    expect(reconstructed.title, 'Belajar Firestore');
    expect(reconstructed.isDone, false);
  });
}
