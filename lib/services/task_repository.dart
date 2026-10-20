import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../models/category.dart';
import '../models/task.dart';

/// Kontrak sumber data tugas.
///
/// Implementasi saat ini memakai JSON lokal, tetapi antarmuka ini siap
/// diganti dengan repository berbasis API tanpa mengubah halaman UI.
abstract class TaskRepository {
  /// Mengambil seluruh kategori.
  Future<List<Category>> getCategories();

  /// Mengambil seluruh tugas.
  Future<List<Task>> getTasks();

  /// Mengambil tugas berdasarkan ID kategori.
  Future<List<Task>> getTasksByCategory(String categoryId);

  /// Mengambil satu tugas berdasarkan ID, atau null bila tidak ditemukan.
  Future<Task?> getTaskById(String id);

  /// Menghitung jumlah tugas untuk setiap ID kategori.
  Future<Map<String, int>> countTasksByCategory();
}

/// Implementasi [TaskRepository] yang membaca data dari aset JSON lokal.
class LocalJsonRepository implements TaskRepository {
  LocalJsonRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const String categoriesAssetPath = 'assets/data/categories.json';
  static const String tasksAssetPath = 'assets/data/tasks.json';

  final AssetBundle _bundle;

  List<Category>? _categoriesCache;
  List<Task>? _tasksCache;

  @override
  Future<List<Category>> getCategories() async {
    _categoriesCache ??= await _loadCategories();
    return List<Category>.unmodifiable(_categoriesCache!);
  }

  @override
  Future<List<Task>> getTasks() async {
    _tasksCache ??= await _loadTasks();
    return List<Task>.unmodifiable(_tasksCache!);
  }

  @override
  Future<List<Task>> getTasksByCategory(String categoryId) async {
    final List<Task> tasks = await getTasks();
    return tasks
        .where((Task task) => task.categoryId == categoryId)
        .toList(growable: false);
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final List<Task> tasks = await getTasks();
    for (final Task task in tasks) {
      if (task.id == id) {
        return task;
      }
    }
    return null;
  }

  @override
  Future<Map<String, int>> countTasksByCategory() async {
    final List<Task> tasks = await getTasks();
    final Map<String, int> counts = <String, int>{};

    for (final Task task in tasks) {
      counts.update(
        task.categoryId,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    return Map<String, int>.unmodifiable(counts);
  }

  /// Memuat kategori dari aset JSON lokal.
  ///
  /// CATATAN API: Saat backend tersedia, ganti pembacaan rootBundle di bawah
  /// dengan pemanggilan HTTP, misalnya `GET /categories`, lalu ubah respons
  /// menjadi `List<Category>`.
  Future<List<Category>> _loadCategories() async {
    final String raw = await _bundle.loadString(categoriesAssetPath);
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;

    return data
        .map((dynamic item) => Category.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Memuat seluruh tugas dari aset JSON lokal.
  ///
  /// CATATAN API: Saat backend tersedia, ganti pembacaan rootBundle di bawah
  /// dengan pemanggilan HTTP, misalnya `GET /tasks`, lalu ubah respons menjadi
  /// `List<Task>`.
  Future<List<Task>> _loadTasks() async {
    final String raw = await _bundle.loadString(tasksAssetPath);
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;

    return data
        .map((dynamic item) => Task.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
