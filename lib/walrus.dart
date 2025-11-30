/// Walrus Flutter SDK - A client library for Walrus decentralized storage.
///
/// This library provides a simple interface to interact with the Walrus
/// decentralized storage network built on Sui blockchain.
///
/// ## Initialization
///
/// ```dart
/// import 'package:walrus/walrus.dart';
///
/// Future<void> main() async {
///   await WalrusClient.initialize(
///     publisherUrl: 'https://publisher.walrus-testnet.walrus.space',
///     aggregatorUrl: 'https://aggregator.walrus-testnet.walrus.space',
///   );
///   runApp(MyApp());
/// }
/// ```
///
/// ## Usage
///
/// ```dart
/// final walrus = WalrusClient.instance;
///
/// // Upload data
/// final data = Uint8List.fromList(utf8.encode('Hello, Walrus!'));
/// final result = await walrus.store(data);
/// print('Blob ID: ${result.blobId}');
///
/// // Download data
/// final retrieved = await walrus.read(result.blobId);
/// print('Content: ${utf8.decode(retrieved)}');
/// ```
library;

export 'src/walrus_client.dart';
export 'src/models/store_response.dart';
export 'src/exceptions/walrus_exception.dart';