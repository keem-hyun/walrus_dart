import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../providers/walrus_provider.dart';
import '../../widgets/section_card.dart';
import '../../widgets/info_row.dart';

/// Response section widget for displaying store response and retrieved content.
class ResponseSection extends ConsumerWidget {
  const ResponseSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walrusProvider);

    if (state.lastStoreResponse == null && state.retrievedContent == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        if (state.lastStoreResponse != null)
          SectionCard(
            title: '📋 Last Store Response',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(label: 'Blob ID', value: state.lastStoreResponse!.blobId),
                InfoRow(label: 'Object ID', value: state.lastStoreResponse!.objectId ?? 'N/A'),
                InfoRow(label: 'Is New', value: state.lastStoreResponse!.isNew.toString()),
                if (state.lastStoreResponse!.endEpoch != null)
                  InfoRow(label: 'End Epoch', value: state.lastStoreResponse!.endEpoch.toString()),
              ],
            ),
          ),
        if (state.retrievedContent != null) ...[
          const SizedBox(height: 20),
          SectionCard(
            title: '📄 Retrieved Content',
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                state.retrievedContent!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
