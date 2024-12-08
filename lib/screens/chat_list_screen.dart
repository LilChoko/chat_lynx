import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Conversaciones')),
      body: FutureBuilder(
        future: chatProvider.fetchChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: chatProvider.chats.length,
            itemBuilder: (context, index) {
              final chat = chatProvider.chats[index];
              return ListTile(
                title: Text(chat['name']),
                onTap: () {
                  Navigator.pushNamed(context, '/chatDetail',
                      arguments: chat['id']);
                },
              );
            },
          );
        },
      ),
    );
  }
}
