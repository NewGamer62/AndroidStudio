import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final Function(String type, String content) onSend;

  const MessageInput({super.key, required this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  String _selectedType = 'MESSAGE';

  final List<String> _types = ['MESSAGE', 'COLOR', 'ICON'];

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    // Envoie le type sélectionné et le contenu au parent (RelationScreen)
    widget.onSend(_selectedType, text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            // Sélecteur de type
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedType,
                items: _types.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value == 'MESSAGE' ? '💬 Texte' : 
                      value == 'COLOR' ? '🎨 Hex' : '😀 Emoji',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() => _selectedType = newValue);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            // Champ de texte dynamique
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: _selectedType == 'MESSAGE' ? 'Votre message...' : 
                            _selectedType == 'COLOR' ? '#FF0000' : 'Un emoji (🔥)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: 8),
            // Bouton d'envoi
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}