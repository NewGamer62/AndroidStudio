import 'dart:convert';
import '../models/element.dart';
import 'api_client.dart';

class ElementService {
  Future<bool> sendElement(ElementModel element) async {
    final res = await ApiClient.post('/element', element.toJson());
    return res.statusCode == 200;
  }

  Future<ElementModel?> getElement(String relationCode) async {
    final res = await ApiClient.get('/element?relationCode=$relationCode');
    if (res.statusCode == 200) {
      return ElementModel.fromJson(jsonDecode(res.body));
    }
    return null;
  }
}