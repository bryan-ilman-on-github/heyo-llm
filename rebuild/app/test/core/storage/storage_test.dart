import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:heyo_rebuild_app/core/storage/client_identity_store.dart';
import 'package:heyo_rebuild_app/core/storage/database_key_store.dart';
import 'package:heyo_rebuild_app/core/storage/key_value_store.dart';

void main() {
  group('ClientIdentityStore', () {
    test('returns the same client id across repeated reads', () async {
      final _InMemoryKeyValueStore keyValueStore = _InMemoryKeyValueStore();
      final ClientIdentityStore clientIdentityStore = ClientIdentityStore(
        keyValueStore: keyValueStore,
        uuid: const Uuid(),
      );

      final String firstValue = await clientIdentityStore
          .readOrCreateClientId();
      final String secondValue = await clientIdentityStore
          .readOrCreateClientId();

      expect(firstValue, isNotEmpty);
      expect(secondValue, firstValue);
    });
  });

  group('DatabaseKeyStore', () {
    test('persists a strong random key', () async {
      final _InMemoryKeyValueStore keyValueStore = _InMemoryKeyValueStore();
      final DatabaseKeyStore databaseKeyStore = DatabaseKeyStore(
        keyValueStore: keyValueStore,
        random: Random(7),
      );

      final String firstValue = await databaseKeyStore.readOrCreateKey();
      final String secondValue = await databaseKeyStore.readOrCreateKey();
      final List<int> decodedBytes = base64Url.decode(firstValue);

      expect(secondValue, firstValue);
      expect(decodedBytes, hasLength(32));
    });
  });
}

class _InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> read({required String key}) async {
    return _values[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }
}
