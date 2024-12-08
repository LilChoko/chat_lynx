import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _chatNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.fetchChats(); // Cargar los chats al iniciar la pantalla
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Conversaciones'),
        backgroundColor: Colors.teal,
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
                  subtitle: Text('Último mensaje...'), // Placeholder
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/chatDetail',
                      arguments: chat['id'],
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateChatDialog(context, chatProvider),
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  /// Muestra un diálogo para crear un nuevo chat
  void _showCreateChatDialog(BuildContext context, ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nuevo Chat'),
          content: TextField(
            controller: _chatNameController,
            decoration: InputDecoration(labelText: 'Nombre del chat'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final chatName = _chatNameController.text.trim();
                if (chatName.isNotEmpty) {
                  chatProvider.createChat(chatName); // Crea el chat
                  _chatNameController.clear();
                  Navigator.pop(context); // Cierra el diálogo
                }
              },
              child: Text('Crear'),
            ),
          ],
        );
      },
    );
  }
}
