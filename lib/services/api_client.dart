import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

/// Mock ApiClient to replace the dead backend for local testing.
/// 
/// This class intercepts all network requests and returns simulated responses.
/// It maintains an in-memory state to allow testing pairing and messaging flows
/// without relying on an external server.
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
  /// 
  /// Intercepts `/pairing` to create a pairing session and `/element` to send a message.
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    await _simulateDelay();
    
    if (endpoint == '/pairing') {
      final code = body['relationCode'];
      _pairings[code] = {
        'status': 'pending',
        'publicKeyA': body['userPublicKey'],
      };
      return http.Response(jsonEncode({'message': 'Created'}), 200);
    } else if (endpoint == '/element') {
      final code = body['relationCode'];
      if (!_elements.containsKey(code)) {
        _elements[code] = [];
      }
      _elements[code]!.add(body);
      return http.Response(jsonEncode({'message': 'Created'}), 200);
    }
    
    return http.Response('Not Found', 404);
  }

  /// Sends a GET request (Mocked)
  /// 
  /// Intercepts `/pairing/:code/status` and `/element?relationCode=:code`.
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
        final el = _elements[code]!.removeAt(0); // Pop the first element
        return http.Response(jsonEncode(el), 200);
      }
      return http.Response('Not Found', 404);
    }
    
    return http.Response('Not Found', 404);
  }

  /// Sends a PUT request (Mocked)
  /// 
  /// Intercepts `/pairing` to finalize pairing from Bob's side.
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
  /// 
  /// Intercepts `/pairing` to finalize pairing from Alice's side and fetch Bob's public key.
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