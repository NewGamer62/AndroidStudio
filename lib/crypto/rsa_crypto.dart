import 'dart:convert';
import 'dart:typed_data';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/api.dart' as pc;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/oaep.dart';

class RSACrypto {
  static String encrypt(String plaintext, String publicKeyPem) {
    final RSAPublicKey publicKey = CryptoUtils.rsaPublicKeyFromPem(publicKeyPem);
    final engine = OAEPEncoding(pc.RSAEngine())
      ..init(true, pc.PublicKeyParameter<RSAPublicKey>(publicKey));
    
    final ciphertext = engine.process(Uint8List.fromList(utf8.encode(plaintext)));
    return base64Encode(ciphertext);
  }

  static String decrypt(String ciphertextB64, String privateKeyPem) {
    final RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(privateKeyPem);
    final engine = OAEPEncoding(pc.RSAEngine())
      ..init(false, pc.PrivateKeyParameter<RSAPrivateKey>(privateKey));
    
    final decrypted = engine.process(base64Decode(ciphertextB64));
    return utf8.decode(decrypted);
  }
}