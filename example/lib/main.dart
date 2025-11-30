import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walrus/walrus.dart';

import 'presentation/pages/walrus_page.dart';
import 'presentation/theme/app_colors.dart';

Future<void> main() async {
  // Initialize WalrusClient with testnet endpoints
  await WalrusClient.initialize(
    publisherUrl: 'https://publisher.walrus-testnet.walrus.space',
    aggregatorUrl: 'https://aggregator.walrus-testnet.walrus.space',
  );

  runApp(
    const ProviderScope(
      child: WalrusExampleApp(),
    ),
  );
}

class WalrusExampleApp extends StatelessWidget {
  const WalrusExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walrus SDK Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryButton,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const WalrusPage(),
    );
  }
}