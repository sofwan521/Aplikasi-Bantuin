import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/task.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'primary_button.dart';

/// Membuka form tambah tugas dan menyimpannya ke state lokal.
Future<bool> showAddTaskSheet(BuildContext context, AppState appState) async {
  final _TaskDraft? draft = await showModalBottomSheet<_TaskDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => const _AddTaskSheet(),
  );

  if (draft == null || !context.mounted) {
    return false;
  }

  final Task task = Task(
    id: 'tugas-lokal-${DateTime.now().microsecondsSinceEpoch}',
    title: draft.title,
    description: draft.description,
    categoryId: 'bantu-rumah',
    rate: draft.rate,
    location: 'Lokasi belum diisi',
    distanceMeters: 0,
    latitude: -6.24,
    longitude: 106.81,
    deadline: DateTime.now().add(const Duration(days: 7)),
    posterName: 'Kamu',
    rating: 5,
    isVerified: true,
    photoUrl: '',
    posterPhotoUrl: '',
    status: TaskStatus.available,
  );

  appState.addTask(task);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('Tugas berhasil ditambahkan')));
  return true;
}

/// Data sementara hasil pengisian form tambah tugas.
class _TaskDraft {
  const _TaskDraft({
    required this.title,
    required this.description,
    required this.rate,
  });

  final String title;
  final String description;
  final int rate;
}

/// Form tambah tugas dengan judul, deskripsi, dan tarif.
class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final int rate = int.tryParse(_rateController.text.trim()) ?? 0;
    Navigator.of(context).pop(
      _TaskDraft(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        rate: rate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          // Batasi lebar form agar tetap nyaman di layar tablet.
          constraints: const BoxConstraints(maxWidth: 640),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Tambah Tugas',
                              style: textTheme.headlineSmall,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            tooltip: 'Tutup',
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _titleController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Judul',
                          hintText: 'Contoh: Mengajak anjing jalan pagi',
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Judul wajib diisi.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          hintText: 'Jelaskan kebutuhan tugasnya',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Deskripsi wajib diisi.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _rateController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Tarif (Rp)',
                          hintText: 'Contoh: 100000',
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? value) {
                          final int? rate = int.tryParse(value?.trim() ?? '');
                          if (rate == null || rate <= 0) {
                            return 'Tarif harus berupa angka lebih dari 0.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PrimaryButton(
                        label: 'Tambah Tugas',
                        icon: Icons.add,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
