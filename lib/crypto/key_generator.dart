import 'dart:math';
import 'dart:typed_data';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/api.dart' as pc;
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/key_generators/api.dart';

class KeyGenerator {
  static FortunaRandom _secureRandom() {
    final random = FortunaRandom();
    final seed = Uint8List(32);
    final r = Random.secure();
    for (var i = 0; i < seed.length; i++) seed[i] = r.nextInt(256);
    random.seed(pc.KeyParameter(seed));
    return random;
  }

  static ({String publicKeyPem, String privateKeyPem}) generateRSAKeyPair() {
    final generator = RSAKeyGenerator()
      ..init(pc.ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        _secureRandom(),
      ));

    final pair = generator.generateKeyPair();
    final publicKey = pair.publicKey as RSAPublicKey;
    final privateKey = pair.privateKey as RSAPrivateKey;

    return (
      publicKeyPem: CryptoUtils.encodeRSAPublicKeyToPem(publicKey),
      privateKeyPem: CryptoUtils.encodeRSAPrivateKeyToPem(privateKey),
    );
  }
}