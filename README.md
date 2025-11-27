# Walrus Dart SDK

[![Pub Version](https://img.shields.io/pub/v/walrus)](https://pub.dev/packages/walrus)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Dart](https://img.shields.io/badge/Dart-3.0+-00B4AB.svg)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-Compatible-02569B.svg)](https://flutter.dev)

A Dart client SDK for [Walrus](https://walrus.xyz), the decentralized storage protocol built on [Sui](https://sui.io) blockchain.

> **Note:** This is a community-maintained SDK. For official SDKs, see [Walrus Documentation](https://docs.walrus.site).

## Features

- [ ] **Store** - Upload blobs to the Walrus network
- [ ] **Read** - Retrieve blobs by their ID
- [ ] **Encryption** - Client-side AES-GCM encryption support
- [ ] **Streaming** - Handle large files with streaming upload/download
- [ ] **Async/Await** - Modern Dart async patterns
- [ ] **Flutter Ready** - Works seamlessly with Flutter mobile apps

## Installation

Add `walrus` to your `pubspec.yaml`:

```yaml
dependencies:
  walrus: ^0.0.1
```

Then run:

```bash
dart pub get
# or for Flutter
flutter pub get
```

## 🚀 Quick Start

### Basic Usage

```dart
import 'package:walrus/walrus.dart';

void main() async {
  // Initialize the client
  final walrus = WalrusClient();

  // Upload data
  final data = Uint8List.fromList(utf8.encode('Hello, Walrus!'));
  final result = await walrus.store(data);
  
  print('Blob ID: ${result.blobId}');
  print('URL: ${walrus.getBlobUrl(result.blobId)}');

  // Download data
  final retrieved = await walrus.read(result.blobId);
  print('Content: ${utf8.decode(retrieved)}');
}
```

### Upload an Image

```dart
import 'dart:io';
import 'package:walrus/walrus.dart';

void main() async {
  final walrus = WalrusClient();

  // Read image file
  final imageBytes = await File('photo.jpg').readAsBytes();
  
  // Upload with 5 epochs storage duration
  final result = await walrus.store(
    imageBytes,
    epochs: 5,
  );

  print('Image URL: ${walrus.getBlobUrl(result.blobId)}');
}
```

### Encrypted Storage

```dart
import 'package:walrus/walrus.dart';

void main() async {
  // Initialize with encryption
  final walrus = WalrusClient(
    encryption: AesGcmEncryption(),
  );

  final sensitiveData = Uint8List.fromList(utf8.encode('Secret message'));
  
  // Encrypt and upload
  final result = await walrus.storeEncrypted(sensitiveData);
  
  print('Blob ID: ${result.blobId}');
  
  // Save these for later decryption!
  print('Key: ${base64Encode(result.encryptionKey)}');
  print('IV: ${base64Encode(result.iv)}');

  // Decrypt and download
  final decrypted = await walrus.readEncrypted(
    result.blobId,
    encryptionKey: result.encryptionKey,
    iv: result.iv,
  );
  
  print('Decrypted: ${utf8.decode(decrypted)}');
}
```

### Custom Configuration

```dart
final walrus = WalrusClient(
  // Use mainnet endpoints
  publisherUrl: 'https://publisher.walrus.site',
  aggregatorUrl: 'https://aggregator.walrus.site',
  
  // Or use testnet (default)
  // publisherUrl: 'https://publisher.walrus-testnet.walrus.space',
  // aggregatorUrl: 'https://aggregator.walrus-testnet.walrus.space',
);
```

## 📖 API Reference

### WalrusClient

#### Constructor

```dart
WalrusClient({
  String publisherUrl,      // Publisher node URL
  String aggregatorUrl,     // Aggregator node URL  
  WalrusEncryption? encryption,  // Optional encryption handler
  Dio? dio,                 // Custom Dio instance
})
```

#### Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `store(Uint8List data, {int? epochs, bool deletable})` | Upload blob to network | `Future<StoreResponse>` |
| `storeFile(String path, {int? epochs, bool deletable})` | Upload file by path | `Future<StoreResponse>` |
| `storeEncrypted(Uint8List data, {int? epochs})` | Encrypt and upload | `Future<EncryptedStoreResponse>` |
| `read(String blobId)` | Download blob by ID | `Future<Uint8List>` |
| `readEncrypted(String blobId, {required key, required iv})` | Download and decrypt | `Future<Uint8List>` |
| `getBlobUrl(String blobId)` | Get HTTP URL for blob | `String` |
| `getMetadata(String blobId)` | Get blob metadata | `Future<BlobMetadata>` |
| `exists(String blobId)` | Check if blob exists | `Future<bool>` |

### StoreResponse

```dart
class StoreResponse {
  final String blobId;      // Unique blob identifier
  final String? objectId;   // Sui Object ID
  final int? endEpoch;      // Storage expiration epoch
  final bool isNew;         // True if newly created
}
```

### EncryptedStoreResponse

```dart
class EncryptedStoreResponse {
  final String blobId;           // Blob ID on Walrus
  final Uint8List encryptionKey; // AES key (keep secret!)
  final Uint8List iv;            // Initialization vector
}
```

## 🔧 Flutter Integration

### Display Walrus Images

```dart
import 'package:cached_network_image/cached_network_image.dart';

class WalrusImage extends StatelessWidget {
  final String blobId;
  final WalrusClient walrus = WalrusClient();

  WalrusImage({required this.blobId});

  @override
  Widget build(BuildContext context) {
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

Future<String?> uploadImage() async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery);
  
  if (image == null) return null;
  
  final bytes = await image.readAsBytes();
  final walrus = WalrusClient();
  final result = await walrus.store(bytes);
  
  return result.blobId;
}
```

## 🌐 Network Endpoints
The following is a list of known public aggregators on Walrus Mainnet; they are checked periodically, but each of them may still be temporarily unavailable:

| Network | Publisher | Aggregator |
|---------|-----------|------------|
| **Testnet** | `https://publisher.walrus-testnet.walrus.space` | `https://aggregator.walrus-testnet.walrus.space` |
| **Mainnet** | (Auth required - No public publisher) | `https://walrus-mainnet-aggregator.nami.cloud` |

> **Note:** On Mainnet, there are no public publishers without authentication, as they consume both SUI and WAL tokens. You need to run your own publisher node or use an authenticated service.

## 🛡️ Error Handling

```dart
try {
  final result = await walrus.store(data);
} on WalrusException catch (e) {
  print('Walrus error: ${e.message}');
} on DioException catch (e) {
  print('Network error: ${e.message}');
}
```

## 🗺️ Roadmap

- [ ] Basic store/read operations
- [ ] AES-GCM encryption
- [ ] Streaming upload/download for large files
- [ ] Sui blockchain integration (Object management)
- [ ] Walrus Sites support
- [ ] Deletable blobs management
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
dart pub get

# Run tests
dart test

# Check formatting
dart format --set-exit-if-changed .

# Analyze code
dart analyze
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Walrus Official Site](https://walrus.xyz)
- [Walrus Documentation](https://docs.walrus.site)
- [Sui Blockchain](https://sui.io)
- [Dart Packages](https://pub.dev)

## 💬 Support

- 📫 Open an [issue](https://github.com/keem-hyun/walrus_dart/issues) for bug reports
- 💡 Start a [discussion](https://github.com/keem-hyun/walrus_dart/discussions) for feature requests
- ⭐ Star this repo if you find it useful!
---

