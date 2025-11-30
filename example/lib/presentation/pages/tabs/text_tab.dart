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

/// Text tab for storing and reading text data.
class TextTab extends ConsumerWidget {
  final TextEditingController inputController;
  final TextEditingController blobIdController;
  final Future<void> Function() onStoreText;
  final Future<void> Function() onReadData;
  final Future<void> Function() onCheckExists;
  final VoidCallback onCopyBlobUrl;

  const TextTab({
    super.key,
    required this.inputController,
    required this.blobIdController,
    required this.onStoreText,
    required this.onReadData,
    required this.onCheckExists,
    required this.onCopyBlobUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walrusProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionCard(
            title: '📤 Store Text',
            child: Column(
              children: [
                TextField(
                  controller: inputController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter text to store on Walrus...',
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  onPressed: onStoreText,
                  icon: const Icon(Icons.cloud_upload),
                  label: 'Store on Walrus',
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
          if (state.errorMessage != null)
            ErrorBanner(message: state.errorMessage!),
          const SizedBox(height: 20),
          const NetworkInfo(),
        ],
      ),
    );
  }
}