import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser!.uid;
    chatProvider.fetchChats(userId); // Cargar los chats al iniciar la pantalla
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Conversaciones'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              Navigator.pushNamed(
                  context, '/contacts'); // Ir a la lista de contactos
            },
          ),
        ],
      ),
      body: chatProvider.chats.isEmpty
          ? Center(
              child: Text(
                'Sin chats aún.',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: chatProvider.chats.length,
              itemBuilder: (context, index) {
                final chat = chatProvider.chats[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Text(
                      chat['name'] != null && chat['name'].isNotEmpty
                          ? chat['name'][0].toUpperCase()
                          : '?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    chat['name'] ?? 'Sin título',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(chat['lastMessage'] ?? 'Sin mensajes aún'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/chatDetail',
                      arguments: chat['id'], // Pasa el ID del chat al detalle
                    );
                  },
                );
              },
            ),
    );
  }
}
