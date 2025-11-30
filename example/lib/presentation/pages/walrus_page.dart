import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../providers/walrus_provider.dart';
import 'tabs/text_tab.dart';
import 'tabs/file_tab.dart';

/// Provider for input text controller.
final inputControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Provider for blob ID text controller.
final blobIdControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Provider for current tab index.
final currentTabProvider = StateProvider<int>((ref) => 0);

/// Main page for Walrus SDK example.
class WalrusPage extends ConsumerWidget {
  const WalrusPage({super.key});

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${isError ? "❌" : "✅"} $message'),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Future<void> _storeText(BuildContext context, WidgetRef ref) async {
    final inputController = ref.read(inputControllerProvider);
    final blobIdController = ref.read(blobIdControllerProvider);
    final notifier = ref.read(walrusProvider.notifier);
    
    await notifier.storeText(inputController.text);

    final state = ref.read(walrusProvider);
    if (state.lastStoreResponse != null && state.errorMessage == null) {
      blobIdController.text = state.lastStoreResponse!.blobId;
      if (context.mounted) {
        _showSnackBar(
          context,
          state.lastStoreResponse!.isNew ? 'New blob stored!' : 'Blob already exists!',
        );
      }
    }
  }

  Future<void> _storeFile(BuildContext context, WidgetRef ref) async {
    final blobIdController = ref.read(blobIdControllerProvider);
    final notifier = ref.read(walrusProvider.notifier);
    
    await notifier.storeFile();

    final state = ref.read(walrusProvider);
    if (state.lastStoreResponse != null && state.errorMessage == null) {
      blobIdController.text = state.lastStoreResponse!.blobId;
      if (context.mounted) {
        _showSnackBar(
          context,
          state.lastStoreResponse!.isNew ? 'File uploaded!' : 'File already exists!',
        );
      }
    }
  }

  Future<void> _readData(WidgetRef ref) async {
    final blobIdController = ref.read(blobIdControllerProvider);
    await ref.read(walrusProvider.notifier).readBlob(blobIdController.text);
  }

  Future<void> _checkExists(BuildContext context, WidgetRef ref) async {
    final blobIdController = ref.read(blobIdControllerProvider);
    final notifier = ref.read(walrusProvider.notifier);
    final exists = await notifier.checkExists(blobIdController.text);

    final state = ref.read(walrusProvider);
    if (state.errorMessage == null && context.mounted) {
      _showSnackBar(context, exists ? 'Blob exists!' : 'Blob not found', isError: !exists);
    }
  }

  void _copyBlobUrl(BuildContext context, WidgetRef ref) {
    final blobIdController = ref.read(blobIdControllerProvider);
    final blobId = blobIdController.text.trim();
    if (blobId.isEmpty) return;

    final url = ref.read(walrusProvider.notifier).getBlobUrl(blobId);
    Clipboard.setData(ClipboardData(text: url));
    _showSnackBar(context, 'URL copied to clipboard!');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputController = ref.watch(inputControllerProvider);
    final blobIdController = ref.watch(blobIdControllerProvider);
    final currentTab = ref.watch(currentTabProvider);

    final tabs = [
      TextTab(
        inputController: inputController,
        blobIdController: blobIdController,
        onStoreText: () => _storeText(context, ref),
        onReadData: () => _readData(ref),
        onCheckExists: () => _checkExists(context, ref),
        onCopyBlobUrl: () => _copyBlobUrl(context, ref),
      ),
      FileTab(
        blobIdController: blobIdController,
        onStoreFile: () => _storeFile(context, ref),
        onReadData: () => _readData(ref),
        onCheckExists: () => _checkExists(context, ref),
        onCopyBlobUrl: () => _copyBlobUrl(context, ref),
      ),
    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
        title: const Row(
          children: [
            Text('🦭', style: TextStyle(fontSize: 28)),
            SizedBox(width: 12),
            Text(
              'Walrus SDK',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
      ),
      body: IndexedStack(
        index: currentTab,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: (index) {
          ref.read(currentTabProvider.notifier).state = index;
        },
        backgroundColor: AppColors.cardBackground,
        indicatorColor: AppColors.primaryButton.withOpacity(0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.text_fields_outlined),
            selectedIcon: Icon(Icons.text_fields),
            label: 'Text',
          ),
          NavigationDestination(
            icon: Icon(Icons.attach_file_outlined),
            selectedIcon: Icon(Icons.attach_file),
            label: 'File',
          ),
        ],
      ),
      ),
    );
  }
}