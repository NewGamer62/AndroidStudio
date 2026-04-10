import 'package:flutter/material.dart';
import 'init_pairing_screen.dart';
import 'scan_pairing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alto - Accueil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InitPairingScreen())),
              child: const Text('Créer une connexion'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanPairingScreen())),
              child: const Text('Scanner un QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}