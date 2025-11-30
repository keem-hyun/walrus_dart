import 'dart:convert';
import 'dart:typed_data';

import 'package:walrus/walrus.dart';

/// Service class that wraps the Walrus SDK client.
/// Acts as the data layer for Walrus operations.
class WalrusService {
  /// Uses the singleton instance of WalrusClient.
  WalrusClient get _client => WalrusClient.instance;

  /// Publisher URL
  String get publisherUrl => _client.publisherUrl;

  /// Aggregator URL
  String get aggregatorUrl => _client.aggregatorUrl;

  /// Store text data on Walrus network.
  Future<StoreResponse> storeText(
    String text, {
    int? epochs,
    bool? deletable,
    bool? permanent,
  }) async {
    final data = Uint8List.fromList(utf8.encode(text));
    return _client.store(
      data,
      epochs: epochs,
      deletable: deletable,
      permanent: permanent,
    );
  }

  /// Store binary data on Walrus network.
  Future<StoreResponse> storeBytes(
    Uint8List data, {
    int? epochs,
    bool? deletable,
    bool? permanent,
  }) async {
    return _client.store(
      data,
      epochs: epochs,
      deletable: deletable,
      permanent: permanent,
    );
  }

  /// Read blob data from Walrus network.
  Future<Uint8List> read(String blobId) async {
    return _client.read(blobId);
  }

  /// Read blob as text from Walrus network.
  /// Returns null if the data is not valid UTF-8.
  Future<String?> readAsText(String blobId) async {
    final data = await _client.read(blobId);
    try {
      return utf8.decode(data);
    } catch (_) {
      return null;
    }
  }

  /// Check if a blob exists on the network.
  Future<bool> exists(String blobId) async {
    return _client.exists(blobId);
  }

  /// Get the HTTP URL for a blob.
  String getBlobUrl(String blobId) {
    return _client.getBlobUrl(blobId);
  }
}