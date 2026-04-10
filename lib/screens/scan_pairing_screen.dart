import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import '../crypto/key_generator.dart';
import '../crypto/key_storage.dart';
import '../services/pairing_service.dart';
import 'relation_screen.dart';

class ScanPairingScreen extends StatefulWidget {
  const ScanPairingScreen({super.key});

  @override
  State<ScanPairingScreen> createState() => _ScanPairingScreenState();
}

class _ScanPairingScreenState extends State<ScanPairingScreen> {
  final _pairingService = PairingService();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final codeA = capture.barcodes.first.rawValue;
    if (codeA == null) return;

    setState(() => _isProcessing = true);
    
    final keys = KeyGenerator.generateRSAKeyPair();
    final codeB = const Uuid().v4();
    await KeyStorage.savePrivateKey(codeB, keys.privateKeyPem);

    final data = await _pairingService.matchBob(codeA, codeB, keys.publicKeyPem);
    if (data != null && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RelationScreen(
        relationCode: codeA, // On utilise le code d'Alice pour l'échange
        myPrivateKey: keys.privateKeyPem,
        otherPublicKey: data['publicKeyA'],
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bob - Scanner Alice')),
      body: MobileScanner(onDetect: _onDetect),
    );
  }
}