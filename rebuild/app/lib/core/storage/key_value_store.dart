import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class KeyValueStore {
  Future<String?> read({required String key});

  Future<void> write({required String key, required String value});
}

class SecureStorageKeyValueStore implements KeyValueStore {
  final FlutterSecureStorage _flutterSecureStorage;

  const SecureStorageKeyValueStore({FlutterSecureStorage? flutterSecureStorage})
    : _flutterSecureStorage =
          flutterSecureStorage ?? const FlutterSecureStorage();

  @override
  Future<String?> read({required String key}) {
    return _flutterSecureStorage.read(key: key);
  }

  @override
  Future<void> write({required String key, required String value}) {
    return _flutterSecureStorage.write(key: key, value: value);
  }
}
