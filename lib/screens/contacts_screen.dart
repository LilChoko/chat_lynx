import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF0B2545),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Contactos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No hay contactos disponibles.',
                style: TextStyle(
                  color: Color(0xFF8A8D91),
                  fontSize: 18,
                ),
              ),
            );
          }

          final users = snapshot.data!.docs
              .where(
                  (doc) => doc.id != currentUserId) // Filtra al usuario actual
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/avatar.png'),
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    user['name'][0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  user['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0B2545),
                  ),
                ),
                subtitle: Text(
                  user['email'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A8D91),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  _startChat(
                    context,
                    user.id, // ID del usuario seleccionado
                    user['name'], // Nombre del usuario seleccionado
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _startChat(
      BuildContext context, String otherUserId, String otherUserName) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Obtener el nombre del usuario actual
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      final currentUserName = currentUserDoc.data()?['name'] ?? 'Sin Nombre';

      // Buscar si ya existe un chat con este usuario
      final chatQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();

      QueryDocumentSnapshot<Map<String, dynamic>>? existingChat;

      for (final doc in chatQuery.docs) {
        if ((doc['participants'] as List).contains(otherUserId)) {
          existingChat = doc; // Guardamos el chat existente
          break;
        }
      }

      String chatId;

      if (existingChat != null) {
        // Si ya existe, usar el ID del chat existente
        chatId = existingChat.id;
      } else {
        // Si no existe, crear uno nuevo
        final newChatRef = FirebaseFirestore.instance.collection('chats').doc();
        chatId = newChatRef.id;

        await newChatRef.set({
          'participants': [currentUserId, otherUserId],
          'lastMessage': '',
          'updatedAt': FieldValue.serverTimestamp(),
          'userNames': {
            currentUserId: currentUserName,
            otherUserId: otherUserName,
          },
        });
      }

      // Redirigir a la pantalla de detalle del chat
      Navigator.pushNamed(context, '/chatDetail', arguments: chatId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar el chat: $e')),
      );
    }
  }
}
