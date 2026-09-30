import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../crypto/key_generator.dart';
import '../crypto/rsa_crypto.dart';

/// Mock ApiClient to replace the dead backend for local testing.
/// 
/// This class intercepts all network requests and returns simulated responses.
/// To allow a single recruiter to test the app locally without a second device,
/// it simulates an intelligent "Bot" (the other party) that automatically
/// joins pairings and replies to messages.
class ApiClient {
  static const String baseUrl = 'https://alto.samyn.ovh';

  // Mock State
  static final Map<String, Map<String, dynamic>> _pairings = {};
  static final Map<String, List<Map<String, dynamic>>> _elements = {};

  /// Simulates network delay to mimic real-world conditions
  static Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Sends a POST request (Mocked)
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    await _simulateDelay();
    
    if (endpoint == '/pairing') {
      final code = body['relationCode'];
      final alicePub = body['userPublicKey'];
      _pairings[code] = {
        'status': 'pending',
        'publicKeyA': alicePub,
      };

      // Auto-simulate Bob (the Bot) joining after 3 seconds for local portfolio testing
      Future.delayed(const Duration(seconds: 3), () {
        if (_pairings.containsKey(code)) {
          final botKeys = KeyGenerator.generateRSAKeyPair();
          _pairings[code]!['status'] = 'completed';
          _pairings[code]!['publicKeyB'] = botKeys.publicKeyPem;
          _pairings[code]!['botPrivateKey'] = botKeys.privateKeyPem;
        }
      });

      return http.Response(jsonEncode({'message': 'Created'}), 200);
    } else if (endpoint == '/element') {
      final code = body['relationCode'];
      
      // Instead of adding the user's message to the fetch queue (which would cause
      // them to fetch their own message and fail to decrypt it), we trigger a Bot reply!
      Future.delayed(const Duration(seconds: 2), () {
        if (!_elements.containsKey(code)) {
          _elements[code] = [];
        }
        final alicePub = _pairings[code]?['publicKeyA'];
        if (alicePub != null) {
          final replyText = "Hello! I am the automated Mock Bot. I received your encrypted message.";
          final encryptedReply = RSACrypto.encrypt(replyText, alicePub);
          
          _elements[code]!.add({
            'relationCode': code,
            'key': 'MESSAGE',
            'value': encryptedReply,
          });
        }
      });

      return http.Response(jsonEncode({'message': 'Created'}), 200);
    }
    
    return http.Response('Not Found', 404);
  }

  /// Sends a GET request (Mocked)
  static Future<http.Response> get(String endpoint) async {
    await _simulateDelay();
    
    if (endpoint.startsWith('/pairing/') && endpoint.endsWith('/status')) {
      final parts = endpoint.split('/');
      final code = parts[2];
      if (_pairings.containsKey(code)) {
        return http.Response(jsonEncode({'status': _pairings[code]!['status']}), 200);
      }
      return http.Response('Not Found', 404);
    } else if (endpoint.startsWith('/element?relationCode=')) {
      final code = endpoint.split('=')[1];
      if (_elements.containsKey(code) && _elements[code]!.isNotEmpty) {
        final el = _elements[code]!.removeAt(0); // Pop the Bot's reply
        return http.Response(jsonEncode(el), 200);
      }
      return http.Response('Not Found', 404);
    }
    
    return http.Response('Not Found', 404);
  }

  /// Sends a PUT request (Mocked)
  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    await _simulateDelay();
    
    if (endpoint == '/pairing') {
      final codeA = body['relationCodeA'];
      if (_pairings.containsKey(codeA)) {
        _pairings[codeA]!['status'] = 'completed';
        _pairings[codeA]!['publicKeyB'] = body['publicKeyB'];
        return http.Response(jsonEncode({'publicKeyA': _pairings[codeA]!['publicKeyA']}), 200);
      }
      return http.Response('Not Found', 404);
    }
    
    return http.Response('Not Found', 404);
  }

  /// Sends a DELETE request (Mocked)
  static Future<http.Response> delete(String endpoint) async {
    await _simulateDelay();
    
    if (endpoint.startsWith('/pairing?relationCodeA=')) {
      final code = endpoint.split('=')[1];
      if (_pairings.containsKey(code)) {
        final pubB = _pairings[code]!['publicKeyB'];
        return http.Response(jsonEncode({'publicKeyB': pubB}), 200);
      }
      return http.Response('Not Found', 404);
    }
    
    return http.Response('Not Found', 404);
  }
}