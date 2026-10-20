import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';

/// Halaman profil pengguna dengan ringkasan aktivitas.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppState appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Card(
            margin: EdgeInsets.zero,
            elevation: 2,
            shadowColor: Colors.black12,
            surfaceTintColor: Colors.transparent,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textPrimary,
                    child: const Icon(Icons.person, size: 32),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengguna Bantuin',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 14,
                              color: AppColors.verified,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Akun terverifikasi',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ProfileStat(
                  icon: Icons.task_alt,
                  label: 'Tugas diambil',
                  value: '0',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ProfileStat(
                  icon: Icons.favorite_border,
                  label: 'Favorit',
                  value: '${appState.favoriteCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            margin: EdgeInsets.zero,
            elevation: 2,
            shadowColor: Colors.black12,
            surfaceTintColor: Colors.transparent,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.assignment_outlined),
                  title: const Text('Tugas Saya'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showComingSoon(
                    context,
                    'Halaman tugas saya segera hadir.',
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Pengaturan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showComingSoon(
                    context,
                    'Halaman pengaturan segera hadir.',
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Bantuan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      _showComingSoon(context, 'Halaman bantuan segera hadir.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu kecil berisi nilai statistik profil.
class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: textTheme.headlineSmall),
            Text(label, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
