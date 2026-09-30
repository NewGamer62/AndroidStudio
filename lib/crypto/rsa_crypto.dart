import 'dart:convert';
import 'dart:typed_data';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/api.dart' as pc;
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/asymmetric/rsa.dart';

/// Provides utility functions for RSA encryption and decryption.
///
/// This class handles encoding data safely for transmission and decrypting
/// received data using asymmetric RSA keys.
class RSACrypto {
  /// Encrypts the given [plaintext] using the provided [publicKeyPem].
  ///
  /// Uses RSA encryption with OAEP padding. The result is returned as a 
  /// Base64 encoded string to allow safe transmission over HTTP or storage.
  /// 
  /// Example:
  /// ```dart
  /// final encryptedText = RSACrypto.encrypt("Hello", publicKey);
  /// ```
  static String encrypt(String plaintext, String publicKeyPem) {
    final RSAPublicKey publicKey = CryptoUtils.rsaPublicKeyFromPem(publicKeyPem);
    final engine = OAEPEncoding(RSAEngine())
      ..init(true, pc.PublicKeyParameter<RSAPublicKey>(publicKey));
    
    final ciphertext = engine.process(Uint8List.fromList(utf8.encode(plaintext)));
    return base64Encode(ciphertext);
  }

  /// Decrypts the given [ciphertextB64] using the provided [privateKeyPem].
  ///
  /// Takes a Base64 encoded ciphertext string, decodes it, and then decrypts
  /// it using RSA with OAEP padding. Returns the original UTF-8 encoded text.
  ///
  /// Example:
  /// ```dart
  /// final text = RSACrypto.decrypt(encryptedText, privateKey);
  /// ```
  static String decrypt(String ciphertextB64, String privateKeyPem) {
    final RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(privateKeyPem);
    final engine = OAEPEncoding(RSAEngine())
      ..init(false, pc.PrivateKeyParameter<RSAPrivateKey>(privateKey));
    
    final decrypted = engine.process(base64Decode(ciphertextB64));
    return utf8.decode(decrypted);
  }
}