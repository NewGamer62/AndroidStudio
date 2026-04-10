import 'dart:async';
import 'package:flutter/material.dart';
import '../models/element.dart';
import '../services/element_service.dart';
import '../crypto/rsa_crypto.dart';
import '../widgets/relation/message_bubble.dart';
import '../widgets/relation/message_input.dart';

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
  
  // Historique local des messages
  final List<Map<String, dynamic>> _messages = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh toutes les 5 secondes (Feature demandée)
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkForNewMessages());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkForNewMessages() async {
    final el = await _service.getElement(widget.relationCode);
    if (el != null) {
      try {
        final decryptedText = RSACrypto.decrypt(el.value, widget.myPrivateKey);
        setState(() {
          _messages.add({
            'content': decryptedText,
            'isMe': false,
            'type': el.key, // MESSAGE, COLOR, ou ICON
          });
        });
      } catch (e) {
        debugPrint("Erreur de déchiffrement: $e");
      }
    }
  }

  void _sendMessage(String type, String content) async {
    setState(() {
      _messages.add({'content': content, 'isMe': true, 'type': type});
    });

    final encrypted = RSACrypto.encrypt(content, widget.otherPublicKey);
    final element = ElementModel(
      relationCode: widget.relationCode,
      key: type, // On envoie le type avec
      value: encrypted,
    );
    await _service.sendElement(element);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Conversation Privée'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkForNewMessages,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return MessageBubble(
                  content: msg['content'],
                  isMe: msg['isMe'],
                  type: msg['type'],
                );
              },
            ),
          ),
          MessageInput(onSend: _sendMessage),
        ],
      ),
    );
  }
}