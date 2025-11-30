/// Base exception for Walrus SDK errors.
class WalrusException implements Exception {
  /// Error message describing what went wrong.
  final String message;

  /// HTTP status code (if applicable).
  final int? statusCode;

  /// Original error that caused this exception.
  final Object? cause;

  const WalrusException(
    this.message, {
    this.statusCode,
    this.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('WalrusException: $message');
    if (statusCode != null) {
      buffer.write(' (status: $statusCode)');
    }
    return buffer.toString();
  }
}

/// Exception thrown when a blob is not found.
class BlobNotFoundException extends WalrusException {
  /// The blob ID that was not found.
  final String blobId;

  const BlobNotFoundException(this.blobId)
      : super('Blob not found: $blobId', statusCode: 404);
}

/// Exception thrown when store operation fails.
class StoreException extends WalrusException {
  const StoreException(super.message, {super.statusCode, super.cause});
}

/// Exception thrown when network request fails.
class NetworkException extends WalrusException {
  const NetworkException(super.message, {super.statusCode, super.cause});
}