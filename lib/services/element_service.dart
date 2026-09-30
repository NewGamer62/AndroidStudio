import 'dart:convert';
import 'dart:async';
import '../models/element.dart';
import 'api_client.dart';

/// Service responsible for managing secure messages (Elements) over the API.
class ElementService {
  /// Sends a secure message (Element) to the server.
  /// 
  /// Returns `true` if successful, otherwise `false`.
  /// Throws a [TimeoutException] if the request takes too long.
  Future<bool> sendElement(ElementModel element) async {
    try {
      final res = await ApiClient.post('/element', element.toJson())
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      // Allow callers to handle exceptions (like TimeoutException) to display a SnackBar
      rethrow;
    }
  }

  /// Retrieves a pending message (Element) for a given [relationCode].
  /// 
  /// Returns the [ElementModel] if found, otherwise `null`.
  /// Throws a [TimeoutException] if the request takes too long.
  Future<ElementModel?> getElement(String relationCode) async {
    try {
      final res = await ApiClient.get('/element?relationCode=$relationCode')
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return ElementModel.fromJson(jsonDecode(res.body));
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}