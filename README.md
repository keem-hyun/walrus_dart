# Walrus Flutter SDK

[![Pub Version](https://img.shields.io/pub/v/walrus)](https://pub.dev/packages/walrus)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B.svg)](https://flutter.dev)

A Flutter SDK for [Walrus](https://walrus.xyz), the decentralized storage protocol built on [Sui](https://sui.io) blockchain.

> **Note:** This is a community-maintained SDK. For official SDKs, see [Walrus Documentation](https://docs.wal.app/).

## Features

- [x] **Store** - Upload blobs to the Walrus network
- [x] **Read** - Retrieve blobs by their ID
- [ ] **Encryption** - Client-side AES-GCM encryption support
- [ ] **Streaming** - Handle large files with streaming upload/download
- [x] **Async/Await** - Modern Dart async patterns
- [x] **Flutter Ready** - Works seamlessly with Flutter mobile apps

## Installation

Add `walrus` to your `pubspec.yaml`:

```yaml
dependencies:
  walrus: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

### Initialization

Initialize once in your app's `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:walrus/walrus.dart';

Future<void> main() async {
  await WalrusClient.initialize(
    publisherUrl: 'https://publisher.walrus-testnet.walrus.space',
    aggregatorUrl: 'https://aggregator.walrus-testnet.walrus.space',
  );
  
  runApp(MyApp());
}
```

### Basic Usage

After initialization, use the singleton instance anywhere:

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:walrus/walrus.dart';

// Get singleton instance
final walrus = WalrusClient.instance;

// Upload data
final data = Uint8List.fromList(utf8.encode('Hello, Walrus!'));
final result = await walrus.store(data);

print('Blob ID: ${result.blobId}');
print('Object ID: ${result.objectId}');
print('Is New: ${result.isNew}');
print('URL: ${walrus.getBlobUrl(result.blobId)}');

// Download data
final retrieved = await walrus.read(result.blobId);
print('Content: ${utf8.decode(retrieved)}');
```

### Upload with Options

```dart
import 'dart:io';
import 'package:walrus/walrus.dart';

final walrus = WalrusClient.instance;

// Read image file
final imageBytes = await File('photo.jpg').readAsBytes();

// Upload with options
final result = await walrus.store(
  imageBytes,
  epochs: 5,           // Storage duration (5 epochs)
  permanent: true,     // Cannot be deleted
  // deletable: true,  // Can be deleted by owner
);

print('Image URL: ${walrus.getBlobUrl(result.blobId)}');
```

> **Important:** Up to (including) Walrus version 1.32, blobs are stored as permanent by default. Starting with version 1.33, newly stored blobs are deletable by default. If you care about blob persistence, make sure to use the appropriate flag.

### Mainnet Configuration

```dart
Future<void> main() async {
  await WalrusClient.initialize(
    publisherUrl: 'https://your-mainnet-publisher.com', // Auth required
    aggregatorUrl: 'https://aggregator.walrus-mainnet.walrus.space',
  );
  
  runApp(MyApp());
}
```

## 📖 API Reference

### WalrusClient

#### Static Methods

| Method | Description |
|--------|-------------|
| `initialize({required String publisherUrl, required String aggregatorUrl, Dio? dio})` | Initialize singleton instance |
| `instance` | Get singleton instance (throws if not initialized) |
| `isInitialized` | Check if initialized |
| `reset()` | Reset singleton (for testing) |

#### Instance Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `store(Uint8List data, {int? epochs, bool? deletable, bool? permanent})` | Upload blob to network | `Future<StoreResponse>` |
| `storeFile(String path, {int? epochs, bool? deletable, bool? permanent})` | Upload file by path | `Future<StoreResponse>` |
| `read(String blobId)` | Download blob by ID | `Future<Uint8List>` |
| `getBlobUrl(String blobId)` | Get HTTP URL for blob | `String` |
| `exists(String blobId)` | Check if blob exists | `Future<bool>` |

### StoreResponse

```dart
class StoreResponse {
  final String blobId;      // Unique blob identifier
  final String? objectId;   // Sui Object ID
  final int? endEpoch;      // Storage expiration epoch
  final bool isNew;         // True if newly created, false if already existed
  final String? mediaType;  // Media type of the blob
}
```

### Exceptions

```dart
// Base exception
class WalrusException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;
}

// Blob not found
class BlobNotFoundException extends WalrusException { }

// Store operation failed
class StoreException extends WalrusException { }

// Network request failed
class NetworkException extends WalrusException { }
```

## 🔧 Flutter Integration

### Display Walrus Images

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:walrus/walrus.dart';

class WalrusImage extends StatelessWidget {
  final String blobId;

  const WalrusImage({required this.blobId});

  @override
  Widget build(BuildContext context) {
    final walrus = WalrusClient.instance;
    
    return CachedNetworkImage(
      imageUrl: walrus.getBlobUrl(blobId),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
```

### Upload from Camera/Gallery

```dart
import 'package:image_picker/image_picker.dart';
import 'package:walrus/walrus.dart';

Future<String?> uploadImage() async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery);
  
  if (image == null) return null;
  
  final bytes = await image.readAsBytes();
  final walrus = WalrusClient.instance;
  final result = await walrus.store(bytes, permanent: true);
  
  return result.blobId;
}
```

## 🌐 Network Endpoints

| Network | Publisher | Aggregator |
|---------|-----------|------------|
| **Testnet** | `https://publisher.walrus-testnet.walrus.space` | `https://aggregator.walrus-testnet.walrus.space` |
| **Mainnet** | (Auth required - No public publisher) | `https://aggregator.walrus-mainnet.walrus.space` |

> **Note:** On Mainnet, there are no public publishers without authentication, as they consume both SUI and WAL tokens. You need to run your own publisher node or use an authenticated service.

## 🛡️ Error Handling

```dart
import 'package:walrus/walrus.dart';

try {
  final walrus = WalrusClient.instance;
  final result = await walrus.store(data);
  print('Stored: ${result.blobId}');
} on StateError catch (e) {
  print('Not initialized: ${e.message}');
} on BlobNotFoundException catch (e) {
  print('Blob not found: ${e.message}');
} on StoreException catch (e) {
  print('Store failed: ${e.message}');
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on WalrusException catch (e) {
  print('Walrus error: ${e.message}');
}
```

## 🗺️ Roadmap

- [x] Basic store/read operations
- [x] Deletable/Permanent blob support
- [ ] AES-GCM encryption
- [ ] Streaming upload/download for large files
- [ ] Sui blockchain integration (Object management)
- [ ] Multi-publisher support
- [ ] Retry with exponential backoff

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create an issue (main)
3. Create your feature branch (`git checkout -b feature/feature-name`)
4. Commit your changes (`git commit -m 'Add some feature'`)
5. Push to the branch (`git push origin feature/feature-name`)
6. Open a Pull Request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/keem-hyun/walrus_dart.git
cd walrus

# Get dependencies
flutter pub get

# Run tests
flutter test

# Check formatting
dart format --set-exit-if-changed .

# Analyze code
dart analyze
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Walrus Official Site](https://walrus.xyz)
- [Walrus Documentation](https://docs.wal.app/)
- [Sui Blockchain](https://sui.io)
- [Pub.dev Package](https://pub.dev/packages/walrus)

## 💬 Support

- 📫 Open an [issue](https://github.com/keem-hyun/walrus_dart/issues) for bug reports
- 💡 Start a [discussion](https://github.com/keem-hyun/walrus_dart/discussions) for feature requests
- ⭐ Star this repo if you find it useful!

---