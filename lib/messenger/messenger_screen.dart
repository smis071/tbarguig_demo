import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/message_model.dart';
import '../../widgets/message_bubble.dart';

class MessengerScreen extends StatefulWidget {
  const MessengerScreen({super.key});
  @override
  State<MessengerScreen> createState() => _MessengerScreenState();
}

class _MessengerScreenState extends State<MessengerScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final List<MessageModel> _messages = [];
  final StreamController<List<MessageModel>> _stream =
      StreamController.broadcast();
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    // seed
    _messages.add(MessageModel(
        id: '1',
        senderId: 'u2',
        text: 'Salut!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2))));
    _messages.add(MessageModel(
        id: '2',
        senderId: 'me',
        text: 'Salut, ça va?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 1))));
    _stream.add(_messages);
  }

  void _send() {
    if (_ctrl.text.trim().isEmpty) return;
    final m = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'me',
        text: _ctrl.text.trim(),
        createdAt: DateTime.now());
    _messages.add(m);
    _stream.add(_messages);
    _ctrl.clear();
    // simulate reply
    Future.delayed(const Duration(seconds: 1), () {
      _messages.add(MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'u2',
          text: 'Bien reçu!',
          createdAt: DateTime.now()));
      _stream.add(_messages);
    });
  }

  @override
  void dispose() {
    _stream.close();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<List<MessageModel>>(
            stream: _stream.stream,
            builder: (context, snap) {
              final msgs = snap.data ?? [];
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: msgs.length,
                itemBuilder: (context, idx) {
                  final m = msgs[msgs.length - 1 - idx];
                  final isMe = m.senderId == 'me';
                  return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: MessageBubble(message: m, isMe: isMe));
                },
              );
            },
          ),
        ),
        if (_typing)
          const Padding(padding: EdgeInsets.all(8), child: Text('...typing')),
        SafeArea(
          child: Row(children: [
            Expanded(
                child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                        hintText: 'Écrire un message...'))),
            IconButton(icon: const Icon(Icons.send), onPressed: _send)
          ]),
        )
      ]),
    );
  }
}
