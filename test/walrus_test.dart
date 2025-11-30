import 'package:flutter_test/flutter_test.dart';
import 'package:walrus/walrus.dart';

void main() {
  group('WalrusClient', () {
    tearDown(() {
      WalrusClient.reset();
    });

    test('throws StateError when not initialized', () {
      expect(
        () => WalrusClient.instance,
        throwsStateError,
      );
    });

    test('isInitialized returns false before initialization', () {
      expect(WalrusClient.isInitialized, false);
    });

    test('isInitialized returns true after initialization', () async {
      await WalrusClient.initialize(
        publisherUrl: 'https://publisher.test.com',
        aggregatorUrl: 'https://aggregator.test.com',
      );
      expect(WalrusClient.isInitialized, true);
    });

    test('instance returns client after initialization', () async {
      await WalrusClient.initialize(
        publisherUrl: 'https://publisher.test.com',
        aggregatorUrl: 'https://aggregator.test.com',
      );
      expect(WalrusClient.instance, isA<WalrusClient>());
    });

    test('reset clears the instance', () async {
      await WalrusClient.initialize(
        publisherUrl: 'https://publisher.test.com',
        aggregatorUrl: 'https://aggregator.test.com',
      );
      WalrusClient.reset();
      expect(WalrusClient.isInitialized, false);
    });

    test('getBlobUrl returns correct URL', () async {
      await WalrusClient.initialize(
        publisherUrl: 'https://publisher.test.com',
        aggregatorUrl: 'https://aggregator.test.com',
      );
      final url = WalrusClient.instance.getBlobUrl('testBlobId');
      expect(url, 'https://aggregator.test.com/v1/blobs/testBlobId');
    });
  });

  group('StoreResponse', () {
    test('fromJson parses newlyCreated response', () {
      final json = {
        'newlyCreated': {
          'blobObject': {
            'id': '0x123',
            'blobId': 'testBlobId',
            'endEpoch': 100,
          },
          'mediaType': 'text/plain',
        },
      };
      final response = StoreResponse.fromJson(json);
      expect(response.blobId, 'testBlobId');
      expect(response.objectId, '0x123');
      expect(response.endEpoch, 100);
      expect(response.isNew, true);
      expect(response.mediaType, 'text/plain');
    });

    test('fromJson parses alreadyCertified response', () {
      final json = {
        'alreadyCertified': {
          'blobId': 'testBlobId',
          'endEpoch': 100,
          'eventOrObject': {
            'Event': {
              'txDigest': '0xabc',
            },
          },
        },
      };
      final response = StoreResponse.fromJson(json);
      expect(response.blobId, 'testBlobId');
      expect(response.objectId, '0xabc');
      expect(response.endEpoch, 100);
      expect(response.isNew, false);
    });

    test('fromJson throws on unknown format', () {
      final json = {'unknown': {}};
      expect(
        () => StoreResponse.fromJson(json),
        throwsFormatException,
      );
    });
  });
}