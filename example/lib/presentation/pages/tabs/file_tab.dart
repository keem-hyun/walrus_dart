import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../providers/walrus_provider.dart';
import '../../widgets/section_card.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';
import '../widgets/read_section.dart';
import '../widgets/response_section.dart';
import '../widgets/network_info.dart';
import '../widgets/file_preview.dart';
import '../widgets/retrieved_image_section.dart';

/// File tab for uploading and reading files.
class FileTab extends ConsumerWidget {
  final TextEditingController blobIdController;
  final Future<void> Function() onStoreFile;
  final Future<void> Function() onReadData;
  final Future<void> Function() onCheckExists;
  final VoidCallback onCopyBlobUrl;

  const FileTab({
    super.key,
    required this.blobIdController,
    required this.onStoreFile,
    required this.onReadData,
    required this.onCheckExists,
    required this.onCopyBlobUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walrusProvider);
    final notifier = ref.read(walrusProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionCard(
            title: '📁 Upload File',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: state.isLoading ? null : notifier.pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Pick Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purpleButton,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: state.isLoading ? null : notifier.pickFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Pick File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warningButton,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const FilePreview(),
                const SizedBox(height: 16),
                PrimaryButton(
                  onPressed: state.selectedFile != null ? onStoreFile : null,
                  icon: const Icon(Icons.cloud_upload),
                  label: 'Upload to Walrus',
                  isLoading: state.isLoading,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ReadSection(
            blobIdController: blobIdController,
            onReadData: onReadData,
            onCheckExists: onCheckExists,
            onCopyBlobUrl: onCopyBlobUrl,
          ),
          const ResponseSection(),
          const RetrievedImageSection(),
          if (state.errorMessage != null)
            ErrorBanner(message: state.errorMessage!),
          const SizedBox(height: 20),
          const NetworkInfo(),
        ],
      ),
    );
  }
}