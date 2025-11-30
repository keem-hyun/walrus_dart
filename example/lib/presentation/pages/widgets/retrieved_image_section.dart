import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/walrus_provider.dart';
import '../../widgets/section_card.dart';

/// Retrieved image section widget for displaying retrieved image.
class RetrievedImageSection extends ConsumerWidget {
  const RetrievedImageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(walrusProvider.select((s) => s.retrievedImage));

    if (image == null) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 20),
        SectionCard(
          title: '🖼️ Retrieved Image',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              image,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}