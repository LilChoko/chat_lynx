import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _selectedIndex = 1; // Inicia en la pestaña "Chats"

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navegación entre las pestañas
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/calls'); // Llamadas
        break;
      case 1:
        // Ya estamos en "Chats", no hacer nada
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile'); // Perfil
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Conversaciones'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              Navigator.pushNamed(context, '/contacts');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Sin chats aún.',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants =
                  List<String>.from(chat['participants']); // Conversión segura
              final otherUserId =
                  participants.firstWhere((id) => id != currentUserId);
              final otherUserName = chat['userNames'][otherUserId];
              final chatId = chat.id;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    otherUserName[0].toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  otherUserName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(chat['lastMessage'] ?? 'Sin mensajes aún'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/chatDetail',
                    arguments: chatId,
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Llamadas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
