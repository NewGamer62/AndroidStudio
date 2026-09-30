import 'dart:convert';
import 'dart:async';
import 'api_client.dart';

/// Service responsible for managing the key exchange and pairing process.
class PairingService {
  /// Initializes a pairing session as Alice (the creator).
  /// 
  /// Sends the initial relation code and Alice's public key to the server.
  /// Throws a [TimeoutException] if the request takes too long.
  Future<bool> initPairing(String code, String publicKey) async {
    try {
      final res = await ApiClient.post('/pairing', {
        'relationCode': code,
        'userPublicKey': publicKey,
      }).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  /// Checks the current status of the pairing session.
  /// 
  /// Returns the status string (e.g., 'pending', 'completed') or 'error' if it fails.
  Future<String> getStatus(String code) async {
    try {
      final res = await ApiClient.get('/pairing/$code/status')
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['status'];
      }
      return 'error';
    } catch (e) {
      return 'error';
    }
  }

  /// Finalizes the pairing process from Alice's side.
  /// 
  /// Retrieves Bob's public key and deletes the pairing session from the server.
  Future<Map<String, dynamic>?> finalizeAlice(String code) async {
    try {
      final res = await ApiClient.delete('/pairing?relationCodeA=$code')
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Finalizes the pairing process from Bob's side.
  /// 
  /// Connects to Alice's existing pairing session, providing Bob's public key.
  Future<Map<String, dynamic>?> matchBob(String codeA, String codeB, String pubB) async {
    try {
      final res = await ApiClient.put('/pairing', {
        'relationCodeA': codeA,
        'relationCodeB': codeB,
        'publicKeyB': pubB,
      }).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (e) {
      rethrow;
    }
  }
}