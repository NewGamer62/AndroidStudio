import 'package:flutter/material.dart';
import '../models/element.dart';
import '../services/element_service.dart';
import '../crypto/rsa_crypto.dart';

class RelationScreen extends StatefulWidget {
  final String relationCode;
  final String myPrivateKey;
  final String otherPublicKey;

  const RelationScreen({
    super.key,
    required this.relationCode,
    required this.myPrivateKey,
    required this.otherPublicKey,
  });

  @override
  State<RelationScreen> createState() => _RelationScreenState();
}

class _RelationScreenState extends State<RelationScreen> {
  final _service = ElementService();
  final _controller = TextEditingController();
  String _lastMessage = "Aucun message";

  void _send() async {
    final encrypted = RSACrypto.encrypt(_controller.text, widget.otherPublicKey);
    final element = ElementModel(
      relationCode: widget.relationCode,
      key: 'MESSAGE',
      value: encrypted,
    );
    await _service.sendElement(element);
    _controller.clear();
  }

  void _refresh() async {
    final el = await _service.getElement(widget.relationCode);
    if (el != null) {
      setState(() {
        _lastMessage = RSACrypto.decrypt(el.value, widget.myPrivateKey);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Échange Sécurisé')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Dernier message reçu : $_lastMessage"),
            const Spacer(),
            TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Message')),
            Row(
              children: [
                IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
                ElevatedButton(onPressed: _send, child: const Text('Envoyer')),
              ],
            )
          ],
        ),
      ),
    );
  }
}