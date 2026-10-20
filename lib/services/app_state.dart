import 'package:flutter/widgets.dart';

import '../models/task.dart';

/// State bersama untuk favorit dan tugas yang ditambahkan pengguna.
class AppState extends ChangeNotifier {
  final Set<String> _favoriteTaskIds = <String>{};
  final List<Task> _localTasks = <Task>[];

  /// Kumpulan ID tugas yang difavoritkan.
  Set<String> get favoriteTaskIds => Set<String>.unmodifiable(_favoriteTaskIds);

  /// Jumlah tugas yang difavoritkan.
  int get favoriteCount => _favoriteTaskIds.length;

  /// Daftar tugas yang ditambahkan secara lokal dari form.
  List<Task> get localTasks => List<Task>.unmodifiable(_localTasks);

  /// Mengecek apakah sebuah tugas sudah difavoritkan.
  bool isFavorite(String taskId) => _favoriteTaskIds.contains(taskId);

  /// Menambah atau menghapus tugas dari favorit.
  void toggleFavorite(String taskId) {
    if (!_favoriteTaskIds.add(taskId)) {
      _favoriteTaskIds.remove(taskId);
    }
    notifyListeners();
  }

  /// Menambahkan tugas baru ke daftar lokal.
  void addTask(Task task) {
    _localTasks.insert(0, task);
    notifyListeners();
  }
}

/// Menyediakan [AppState] ke seluruh pohon widget aplikasi.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// Mengambil state sekaligus mendaftarkan widget agar ikut rebuild.
  static AppState of(BuildContext context) {
    final AppStateScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope tidak ditemukan di pohon widget.');
    return scope!.notifier!;
  }

  /// Mengambil state tanpa mendaftarkan dependensi rebuild.
  static AppState read(BuildContext context) {
    final AppStateScope? scope = context
        .getInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope tidak ditemukan di pohon widget.');
    return scope!.notifier!;
  }
}
