import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Contactos'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs
              .where(
                  (doc) => doc.id != currentUserId) // Filtra al usuario actual
              .toList();

          if (users.isEmpty) {
            return Center(child: Text('No hay contactos disponibles.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Text(user['name'][0].toUpperCase()),
                ),
                title: Text(user['name']),
                subtitle: Text(user['email']),
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
