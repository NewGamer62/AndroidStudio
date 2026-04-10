import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final String type; // 'MESSAGE', 'COLOR', 'ICON'

  const MessageBubble({super.key, required this.content, required this.isMe, required this.type});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.deepPurple[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (type == 'COLOR') {
      return Container(
        width: 50, height: 50,
        color: Color(int.parse(content.replaceAll('#', '0xFF'))),
      );
    }
    return Text(content, style: const TextStyle(fontSize: 16));
  }
}