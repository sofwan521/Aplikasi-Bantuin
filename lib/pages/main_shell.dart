import 'package:flutter/material.dart';

import '../services/task_repository.dart';
import '../theme/app_theme.dart';
import 'chat_page.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'my_tasks_page.dart';
import 'profile_page.dart';

/// Kerangka utama aplikasi dengan navigasi bawah lima item.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.repository});

  /// Repository opsional agar mudah diganti saat memakai API atau diuji.
  final TaskRepository? repository;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final TaskRepository _repository;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocalJsonRepository();
  }

  /// Indeks halaman pada [IndexedStack] tanpa tombol Tugas Saya.
  int get _pageIndex {
    if (_navIndex <= 1) {
      return _navIndex;
    }
    return _navIndex - 1;
  }

  void _onNavTap(int index) {
    if (index == 2) {
      _openMyTasks();
      return;
    }

    setState(() {
      _navIndex = index;
    });
  }

  void _openMyTasks() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MyTasksPage(repository: _repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _pageIndex,
        children: [
          HomePage(repository: _repository),
          FavoritesPage(repository: _repository),
          const ChatPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: _MainBottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

/// Navigasi bawah dengan tombol Tugas Saya kuning yang menonjol di tengah.
class _MainBottomNavigationBar extends StatelessWidget {
  const _MainBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: AppSpacing.bottomNav + 4,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: onTap,
                type: BottomNavigationBarType.fixed,
                backgroundColor: AppColors.surface,
                selectedItemColor: AppColors.textPrimary,
                unselectedItemColor: AppColors.textSecondary,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                elevation: 8,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border),
                    activeIcon: Icon(Icons.favorite),
                    label: 'Favorit',
                  ),
                  BottomNavigationBarItem(
                    icon: SizedBox(width: 24, height: 24),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline),
                    activeIcon: Icon(Icons.chat_bubble),
                    label: 'Chat',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Tooltip(
                  message: 'Tugas Saya',
                  child: Material(
                    color: AppColors.accent,
                    shape: const CircleBorder(),
                    elevation: 6,
                    shadowColor: Colors.black26,
                    child: InkWell(
                      onTap: () => onTap(2),
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(
                          Icons.checklist_rounded,
                          size: 30,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
