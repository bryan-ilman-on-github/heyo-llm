import 'dart:convert';
import 'dart:math';

import 'key_value_store.dart';

class DatabaseKeyStore {
  static const String _databaseKeyName = 'heyo_rebuild_database_key';

  final KeyValueStore _keyValueStore;
  final Random _random;

  DatabaseKeyStore({KeyValueStore? keyValueStore, Random? random})
    : _keyValueStore = keyValueStore ?? const SecureStorageKeyValueStore(),
      _random = random ?? Random.secure();

  Future<String> readOrCreateKey() async {
    final existingKey = await _keyValueStore.read(key: _databaseKeyName);
    if (existingKey != null && existingKey.isNotEmpty) {
      return existingKey;
    }

    final List<int> generatedBytes = List<int>.generate(
      32,
      (int _) => _random.nextInt(256),
      growable: false,
    );
    final String generatedKey = base64UrlEncode(generatedBytes);
    await _keyValueStore.write(key: _databaseKeyName, value: generatedKey);
    return generatedKey;
  }
}
