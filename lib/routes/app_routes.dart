import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/task.dart';
import '../pages/category_page.dart';
import '../pages/chat_page.dart';
import '../pages/detail_page.dart';
import '../pages/favorites_page.dart';
import '../pages/map_page.dart';
import '../pages/my_tasks_page.dart';
import '../pages/profile_page.dart';

/// Kumpulan nama dan definisi rute navigasi aplikasi.
class AppRoutes {
  AppRoutes._();

  static const String category = '/kategori';
  static const String detail = '/detail';
  static const String map = '/peta';
  static const String favorites = '/favorit';
  static const String chat = '/chat';
  static const String profile = '/profil';
  static const String myTasks = '/tugas-saya';

  /// Rute tanpa argumen yang bisa didaftarkan langsung ke [MaterialApp].
  static Map<String, WidgetBuilder> get routes => <String, WidgetBuilder>{
    favorites: (_) => const FavoritesPage(),
    chat: (_) => const ChatPage(),
    profile: (_) => const ProfilePage(),
    myTasks: (_) => const MyTasksPage(),
  };

  /// Membuat rute yang membutuhkan argumen model.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == category) {
      final Object? arguments = settings.arguments;
      if (arguments is Category) {
        return MaterialPageRoute<void>(
          builder: (_) => CategoryPage(category: arguments),
          settings: settings,
        );
      }
      return null;
    }

    if (settings.name == detail) {
      final Object? arguments = settings.arguments;
      if (arguments is Task) {
        return MaterialPageRoute<void>(
          builder: (_) => DetailPage(task: arguments),
          settings: settings,
        );
      }
      return null;
    }

    if (settings.name == map) {
      return MaterialPageRoute<void>(
        builder: (_) => const MapPage(),
        settings: settings,
      );
    }

    return null;
  }
}
