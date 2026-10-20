import 'package:flutter/widgets.dart';

import '../models/task.dart';

/// State bersama untuk favorit dan tugas yang telah diambil agen.
class AppState extends ChangeNotifier {
  final Set<String> _favoriteTaskIds = <String>{};
  final Set<String> _takenTaskIds = <String>{};

  /// Kumpulan ID tugas yang difavoritkan.
  Set<String> get favoriteTaskIds => Set<String>.unmodifiable(_favoriteTaskIds);

  /// Jumlah tugas yang difavoritkan.
  int get favoriteCount => _favoriteTaskIds.length;

  /// Mengecek apakah sebuah tugas sudah difavoritkan.
  bool isFavorite(String taskId) => _favoriteTaskIds.contains(taskId);

  /// Menambah atau menghapus tugas dari favorit.
  void toggleFavorite(String taskId) {
    if (!_favoriteTaskIds.add(taskId)) {
      _favoriteTaskIds.remove(taskId);
    }
    notifyListeners();
  }

  /// Mengecek apakah tugas sudah diambil oleh agen.
  bool isTaken(String taskId) => _takenTaskIds.contains(taskId);

  /// Mencatat tugas yang telah diambil agar tampil di halaman Tugas Saya.
  void takeTask(String taskId) {
    if (_takenTaskIds.add(taskId)) {
      notifyListeners();
    }
  }

  /// Memfilter [tasks] menjadi tugas yang telah diambil.
  ///
  /// Tugas berstatus diambil pada JSON dan tugas yang tercatat di state tetap
  /// dihitung satu kali karena penyaringan dilakukan per objek tugas.
  List<Task> takenTasksFrom(Iterable<Task> tasks) {
    return tasks
        .where(
          (Task task) => task.status == TaskStatus.taken || isTaken(task.id),
        )
        .toList(growable: false);
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
