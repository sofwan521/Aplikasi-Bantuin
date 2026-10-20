import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Halaman daftar percakapan dengan pemosting tugas.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  static final List<_ChatThread> _threads = <_ChatThread>[
    _ChatThread(
      name: 'Rania Putri',
      message: 'Halo, apakah kamu masih bisa membantu pagi ini?',
      time: '09.41',
    ),
    _ChatThread(
      name: 'Bagas Pratama',
      message: 'Terima kasih sudah membantu pindahan kemarin.',
      time: 'Kemarin',
    ),
    _ChatThread(
      name: 'Dinda Ayu',
      message: 'Belanjaannya sudah saya siapkan di dapur.',
      time: 'Sen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: _threads.isEmpty
          ? const _EmptyChatState()
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screen),
              itemCount: _threads.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) {
                final _ChatThread thread = _threads[index];
                final String initial = thread.name.characters.first
                    .toUpperCase();

                return Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shadowColor: Colors.black12,
                  surfaceTintColor: Colors.transparent,
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textPrimary,
                      child: Text(
                        initial,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      thread.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      thread.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                    trailing: SizedBox(
                      width: 52,
                      child: Text(
                        thread.time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: textTheme.bodySmall,
                      ),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              'Chat dengan ${thread.name} segera hadir.',
                            ),
                          ),
                        );
                    },
                  ),
                );
              },
            ),
    );
  }
}

/// Tampilan saat belum ada percakapan.
class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Belum ada percakapan',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Percakapan dengan pemosting tugas akan tampil di sini.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Data ringkas satu percakapan.
class _ChatThread {
  const _ChatThread({
    required this.name,
    required this.message,
    required this.time,
  });

  final String name;
  final String message;
  final String time;
}
