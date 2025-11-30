import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walrus/walrus.dart';

import '../../data/services/walrus_service.dart';
import '../../data/services/file_picker_service.dart';

/// State class for Walrus operations.
class WalrusState {
  final bool isLoading;
  final String? errorMessage;
  final StoreResponse? lastStoreResponse;
  final String? retrievedContent;
  final Uint8List? retrievedImage;
  final PickedFile? selectedFile;

  const WalrusState({
    this.isLoading = false,
    this.errorMessage,
    this.lastStoreResponse,
    this.retrievedContent,
    this.retrievedImage,
    this.selectedFile,
  });

  WalrusState copyWith({
    bool? isLoading,
    String? errorMessage,
    StoreResponse? lastStoreResponse,
    String? retrievedContent,
    Uint8List? retrievedImage,
    PickedFile? selectedFile,
    bool clearError = false,
    bool clearRetrieved = false,
    bool clearSelectedFile = false,
  }) {
    return WalrusState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastStoreResponse: lastStoreResponse ?? this.lastStoreResponse,
      retrievedContent: clearRetrieved ? null : (retrievedContent ?? this.retrievedContent),
      retrievedImage: clearRetrieved ? null : (retrievedImage ?? this.retrievedImage),
      selectedFile: clearSelectedFile ? null : (selectedFile ?? this.selectedFile),
    );
  }
}

/// Notifier for Walrus operations.
class WalrusNotifier extends StateNotifier<WalrusState> {
  final WalrusService _walrusService;
  final FilePickerService _filePickerService;

  WalrusNotifier({
    WalrusService? walrusService,
    FilePickerService? filePickerService,
  })  : _walrusService = walrusService ?? WalrusService(),
        _filePickerService = filePickerService ?? FilePickerService(),
        super(const WalrusState());

  // Expose service properties
  String get publisherUrl => _walrusService.publisherUrl;
  String get aggregatorUrl => _walrusService.aggregatorUrl;

  /// Store text on Walrus network.
  Future<void> storeText(String text) async {
    if (text.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter some text to store');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _walrusService.storeText(text);
      state = state.copyWith(
        isLoading: false,
        lastStoreResponse: result,
      );
    } on WalrusException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Store file on Walrus network.
  Future<void> storeFile() async {
    final file = state.selectedFile;
    if (file == null) {
      state = state.copyWith(errorMessage: 'Please select a file first');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _walrusService.storeBytes(file.bytes);
      state = state.copyWith(
        isLoading: false,
        lastStoreResponse: result,
      );
    } on WalrusException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Read blob from Walrus network.
  Future<void> readBlob(String blobId) async {
    if (blobId.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter a Blob ID to read');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true, clearRetrieved: true);

    try {
      final data = await _walrusService.read(blobId);
      final textContent = await _walrusService.readAsText(blobId);

      if (textContent != null) {
        state = state.copyWith(
          isLoading: false,
          retrievedContent: textContent,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          retrievedImage: data,
        );
      }
    } on BlobNotFoundException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Blob not found: $blobId',
      );
    } on WalrusException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Check if blob exists.
  Future<bool> checkExists(String blobId) async {
    if (blobId.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter a Blob ID to check');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final exists = await _walrusService.exists(blobId);
      state = state.copyWith(isLoading: false);
      return exists;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Pick image from gallery.
  Future<void> pickImage() async {
    try {
      final file = await _filePickerService.pickImage();
      if (file != null) {
        state = state.copyWith(selectedFile: file);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to pick image: $e');
    }
  }

  /// Pick any file.
  Future<void> pickFile() async {
    try {
      final file = await _filePickerService.pickFile();
      if (file != null) {
        state = state.copyWith(selectedFile: file);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to pick file: $e');
    }
  }

  /// Clear selected file.
  void clearSelectedFile() {
    state = state.copyWith(clearSelectedFile: true);
  }

  /// Clear error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Get blob URL.
  String getBlobUrl(String blobId) {
    return _walrusService.getBlobUrl(blobId);
  }
}

/// Provider for WalrusNotifier.
final walrusProvider = StateNotifierProvider<WalrusNotifier, WalrusState>((ref) {
  return WalrusNotifier();
});

/// Provider for blob ID text.
final blobIdProvider = StateProvider<String>((ref) => '');

/// Provider for input text.
final inputTextProvider = StateProvider<String>((ref) => '');