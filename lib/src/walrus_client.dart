import 'dart:typed_data';
import 'dart:io';

import 'package:dio/dio.dart';

import 'models/store_response.dart';
import 'exceptions/walrus_exception.dart';

/// A client for interacting with the Walrus decentralized storage network.
///
/// ## Initialization
///
/// Initialize once in your app's main function:
/// ```dart
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
/// After initialization, use the singleton instance anywhere:
/// ```dart
/// final walrus = WalrusClient.instance;
/// final result = await walrus.store(data);
/// ```
class WalrusClient {
  static WalrusClient? _instance;

  /// Returns the singleton instance.
  ///
  /// Throws [StateError] if [initialize] has not been called.
  static WalrusClient get instance {
    if (_instance == null) {
      throw StateError(
        'WalrusClient has not been initialized. '
        'Call WalrusClient.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initializes the singleton instance with the given configuration.
  ///
  /// Must be called once before using [instance].
  ///
  /// [publisherUrl] - Publisher node URL for uploading blobs.
  /// [aggregatorUrl] - Aggregator node URL for downloading blobs.
  /// [dio] - Optional custom Dio instance for HTTP requests.
  ///
  /// Example:
  /// ```dart
  /// Future<void> main() async {
  ///   await WalrusClient.initialize(
  ///     publisherUrl: 'https://publisher.walrus-testnet.walrus.space',
  ///     aggregatorUrl: 'https://aggregator.walrus-testnet.walrus.space',
  ///   );
  ///   runApp(MyApp());
  /// }
  /// ```
  static Future<void> initialize({
    required String publisherUrl,
    required String aggregatorUrl,
    Dio? dio,
  }) async {
    _instance = WalrusClient._(
      publisherUrl: publisherUrl,
      aggregatorUrl: aggregatorUrl,
      dio: dio ?? Dio(),
    );
  }

  /// Resets the singleton instance.
  /// Useful for testing or re-initialization.
  static void reset() {
    _instance = null;
  }

  /// Whether the client has been initialized.
  static bool get isInitialized => _instance != null;

  /// Publisher node URL for uploading blobs.
  final String publisherUrl;

  /// Aggregator node URL for downloading blobs.
  final String aggregatorUrl;

  /// HTTP client for making requests.
  final Dio _dio;

  /// Private constructor for singleton.
  WalrusClient._({
    required this.publisherUrl,
    required this.aggregatorUrl,
    required Dio dio,
  }) : _dio = dio;

  /// Uploads a blob to the Walrus network.
  ///
  /// [data] - The binary data to upload.
  /// [epochs] - Number of epochs to store the blob (optional).
  /// [deletable] - Store as a deletable blob (can be deleted by owner).
  /// [permanent] - Store as a permanent blob (cannot be deleted).
  ///
  /// Note: Only one of [deletable] or [permanent] should be set to true.
  /// If neither is set, the publisher uses its default behavior.
  ///
  /// **Important:** Up to (including) walrus version 1.32, blobs are stored as
  /// permanent by default. Starting with version 1.33, newly stored blobs
  /// are deletable by default. If you care about blob persistence, make
  /// sure to use the appropriate flag.
  ///
  /// Returns a [StoreResponse] containing the blob ID and metadata.
  ///
  /// Throws [StoreException] if the upload fails.
  Future<StoreResponse> store(
    Uint8List data, {
    int? epochs,
    bool? deletable,
    bool? permanent,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (epochs != null) {
        queryParams['epochs'] = epochs;
      }
      if (deletable == true) {
        queryParams['deletable'] = true;
      }
      if (permanent == true) {
        queryParams['permanent'] = true;
      }

      final response = await _dio.put<Map<String, dynamic>>(
        '$publisherUrl/v1/blobs',
        data: Stream.fromIterable([data]),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          headers: {
            'Content-Type': 'application/octet-stream',
            'Content-Length': data.length,
          },
          responseType: ResponseType.json,
        ),
      );

      if (response.data == null) {
        throw const StoreException('Empty response from publisher');
      }

      return StoreResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw StoreException(
        e.message ?? 'Failed to store blob',
        statusCode: e.response?.statusCode,
        cause: e,
      );
    }
  }

  /// Uploads a file to the Walrus network.
  ///
  /// [path] - Path to the file to upload.
  /// [epochs] - Number of epochs to store the blob (optional).
  /// [deletable] - Store as a deletable blob (can be deleted by owner).
  /// [permanent] - Store as a permanent blob (cannot be deleted).
  ///
  /// Returns a [StoreResponse] containing the blob ID and metadata.
  Future<StoreResponse> storeFile(
    String path, {
    int? epochs,
    bool? deletable,
    bool? permanent,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StoreException('File not found: $path');
    }

    final bytes = await file.readAsBytes();
    return store(bytes, epochs: epochs, deletable: deletable, permanent: permanent);
  }

  /// Retrieves a blob from the Walrus network.
  ///
  /// [blobId] - The unique identifier of the blob to retrieve.
  ///
  /// Returns the blob data as [Uint8List].
  ///
  /// Throws [BlobNotFoundException] if the blob doesn't exist.
  /// Throws [NetworkException] if the request fails.
  Future<Uint8List> read(String blobId) async {
    try {
      final response = await _dio.get<List<int>>(
        '$aggregatorUrl/v1/blobs/$blobId',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.data == null) {
        throw BlobNotFoundException(blobId);
      }

      return Uint8List.fromList(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw BlobNotFoundException(blobId);
      }
      throw NetworkException(
        e.message ?? 'Failed to read blob',
        statusCode: e.response?.statusCode,
        cause: e,
      );
    }
  }

  /// Returns the HTTP URL for accessing a blob.
  ///
  /// [blobId] - The unique identifier of the blob.
  ///
  /// This URL can be used directly in browsers or image widgets.
  String getBlobUrl(String blobId) {
    return '$aggregatorUrl/v1/blobs/$blobId';
  }

  /// Checks if a blob exists on the network.
  ///
  /// [blobId] - The unique identifier of the blob to check.
  ///
  /// Returns `true` if the blob exists, `false` otherwise.
  Future<bool> exists(String blobId) async {
    try {
      final response = await _dio.head(
        '$aggregatorUrl/v1/blobs/$blobId',
      );
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }
}