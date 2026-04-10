import 'dart:convert';
import 'api_client.dart';

class PairingService {
  Future<bool> initPairing(String code, String publicKey) async {
    final res = await ApiClient.post('/pairing', {
      'relationCode': code,
      'userPublicKey': publicKey,
    });
    return res.statusCode == 200;
  }

  Future<String> getStatus(String code) async {
    final res = await ApiClient.get('/pairing/$code/status');
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['status'];
    }
    return 'error';
  }

  Future<Map<String, dynamic>?> finalizeAlice(String code) async {
    final res = await ApiClient.delete('/pairing?relationCodeA=$code');
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  Future<Map<String, dynamic>?> matchBob(String codeA, String codeB, String pubB) async {
    final res = await ApiClient.put('/pairing', {
      'relationCodeA': codeA,
      'relationCodeB': codeB,
      'publicKeyB': pubB,
    });
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }
}