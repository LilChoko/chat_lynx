import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'No date'; // Valor por defecto si es null
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF0B2545),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mensajes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
                'No conversations yet.',
                style: TextStyle(color: Color(0xFF8A8D91), fontSize: 18),
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
              final lastMessage = chat['lastMessage'] ?? '';
              final updatedAt = chat['updatedAt'] != null
                  ? chat['updatedAt'] as Timestamp
                  : null;

              final formattedTime = _formatTimestamp(updatedAt);

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/avatar.png'),
                  radius: 28,
                  child: Text(
                    otherUserName[0].toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.white,
                ),
                title: Text(
                  otherUserName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0B2545),
                  ),
                ),
                subtitle: Text(
                  lastMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A8D91),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8D91),
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/chatDetail',
                    arguments: chat.id,
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Color(0xFF0B2545),
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFF8A8D91),
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.call),
              label: 'Calls',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(bottom: 60.0), // Ajusta la posición vertical
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/contacts');
          },
          backgroundColor: Color(0xFF0B2545),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
