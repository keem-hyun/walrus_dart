import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../providers/walrus_provider.dart';
import '../../widgets/section_card.dart';

/// Read section widget for reading blob data.
class ReadSection extends ConsumerWidget {
  final TextEditingController blobIdController;
  final Future<void> Function() onReadData;
  final Future<void> Function() onCheckExists;
  final VoidCallback onCopyBlobUrl;

  const ReadSection({
    super.key,
    required this.blobIdController,
    required this.onReadData,
    required this.onCheckExists,
    required this.onCopyBlobUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(walrusProvider.select((s) => s.isLoading));

    return SectionCard(
      title: '📥 Read Data',
      child: Column(
        children: [
          TextField(
            controller: blobIdController,
            decoration: InputDecoration(
              hintText: 'Enter Blob ID...',
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: onCopyBlobUrl,
                tooltip: 'Copy Blob URL',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onReadData,
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Read'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successButton,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onCheckExists,
                  icon: const Icon(Icons.search),
                  label: const Text('Check'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleButton,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}