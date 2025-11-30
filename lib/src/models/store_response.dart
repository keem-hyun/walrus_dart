/// Response from storing a blob on Walrus network.
class StoreResponse {
  /// Unique blob identifier on the Walrus network.
  final String blobId;

  /// Sui Object ID (if available).
  final String? objectId;

  /// Storage expiration epoch.
  final int? endEpoch;

  /// True if this blob was newly created, false if it already existed.
  final bool isNew;

  /// Media type of the stored blob.
  final String? mediaType;

  const StoreResponse({
    required this.blobId,
    this.objectId,
    this.endEpoch,
    required this.isNew,
    this.mediaType,
  });

  /// Creates a [StoreResponse] from JSON response.
  factory StoreResponse.fromJson(Map<String, dynamic> json) {
    // Handle "newlyCreated" response
    if (json.containsKey('newlyCreated')) {
      final newlyCreated = json['newlyCreated'] as Map<String, dynamic>;
      final blobObject = newlyCreated['blobObject'] as Map<String, dynamic>;
      return StoreResponse(
        blobId: blobObject['blobId'] as String,
        objectId: blobObject['id'] as String?,
        endEpoch: blobObject['endEpoch'] as int?,
        isNew: true,
        mediaType: newlyCreated['mediaType'] as String?,
      );
    }

    // Handle "alreadyCertified" response
    if (json.containsKey('alreadyCertified')) {
      final alreadyCertified = json['alreadyCertified'] as Map<String, dynamic>;
      return StoreResponse(
        blobId: alreadyCertified['blobId'] as String,
        objectId: alreadyCertified['eventOrObject']?['Event']?['txDigest'] as String?,
        endEpoch: alreadyCertified['endEpoch'] as int?,
        isNew: false,
        mediaType: alreadyCertified['mediaType'] as String?,
      );
    }

    throw FormatException('Unknown store response format: $json');
  }

  @override
  String toString() {
    return 'StoreResponse(blobId: $blobId, objectId: $objectId, endEpoch: $endEpoch, isNew: $isNew, mediaType: $mediaType)';
  }
}