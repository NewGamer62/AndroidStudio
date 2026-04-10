import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> savePrivateKey(String relationId, String pem) async {
    await _storage.write(key: 'priv_$relationId', value: pem);
  }

  static Future<String?> getPrivateKey(String relationId) async {
    return await _storage.read(key: 'priv_$relationId');
  }
}