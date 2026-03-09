import 'package:uuid/uuid.dart';

import 'key_value_store.dart';

class ClientIdentityStore {
  static const String _clientIdentityKey = 'heyo_rebuild_client_id';

  final KeyValueStore _keyValueStore;
  final Uuid _uuid;

  ClientIdentityStore({KeyValueStore? keyValueStore, Uuid? uuid})
    : _keyValueStore = keyValueStore ?? const SecureStorageKeyValueStore(),
      _uuid = uuid ?? const Uuid();

  Future<String> readOrCreateClientId() async {
    final String? existingValue = await _keyValueStore.read(
      key: _clientIdentityKey,
    );
    if (existingValue != null && existingValue.isNotEmpty) {
      return existingValue;
    }

    final String generatedValue = _uuid.v4();
    await _keyValueStore.write(key: _clientIdentityKey, value: generatedValue);
    return generatedValue;
  }
}
