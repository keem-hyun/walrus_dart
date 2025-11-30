import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/walrus_provider.dart';
import '../../widgets/section_card.dart';
import '../../widgets/info_row.dart';

/// Network info widget for displaying publisher and aggregator URLs.
class NetworkInfo extends ConsumerWidget {
  const NetworkInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(walrusProvider.notifier);

    return SectionCard(
      title: '🌐 Network Info',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(label: 'Publisher', value: notifier.publisherUrl),
          InfoRow(label: 'Aggregator', value: notifier.aggregatorUrl),
        ],
      ),
    );
  }
}