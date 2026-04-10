import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import '../crypto/key_generator.dart';
import '../crypto/key_storage.dart';
import '../services/pairing_service.dart';
import 'relation_screen.dart';

class InitPairingScreen extends StatefulWidget {
  const InitPairingScreen({super.key});

  @override
  State<InitPairingScreen> createState() => _InitPairingScreenState();
}

class _InitPairingScreenState extends State<InitPairingScreen> {
  final _pairingService = PairingService();
  String? _relationCode;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _setupPairing();
  }

  void _setupPairing() async {
    final keys = KeyGenerator.generateRSAKeyPair();
    final code = const Uuid().v4();
    await KeyStorage.savePrivateKey(code, keys.privateKeyPem);
    
    final success = await _pairingService.initPairing(code, keys.publicKeyPem);
    if (success) {
      setState(() => _relationCode = code);
      _startPolling(code, keys.privateKeyPem);
    }
  }

  void _startPolling(String code, String privKey) {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final status = await _pairingService.getStatus(code);
      if (status == 'completed') {
        timer.cancel();
        final data = await _pairingService.finalizeAlice(code);
        if (data != null && mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RelationScreen(
            relationCode: code,
            myPrivateKey: privKey,
            otherPublicKey: data['publicKeyB'],
          )));
        }
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alice - Attente de Bob')),
      body: Center(
        child: _relationCode == null 
          ? const CircularProgressIndicator()
          : QrImageView(data: _relationCode!, size: 250),
      ),
    );
  }
}