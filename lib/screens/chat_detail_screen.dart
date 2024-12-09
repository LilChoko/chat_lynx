import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatDetailScreen extends StatelessWidget {
  final String chatId;

  ChatDetailScreen({required this.chatId});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0B2545),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('chats').doc(chatId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text(
                'Cargando...',
                style: TextStyle(color: Colors.white),
              );
            }
            final chatData = snapshot.data!.data() as Map<String, dynamic>;
            final participants = List<String>.from(chatData['participants']);
            final otherUserId =
                participants.firstWhere((id) => id != currentUserId);

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherUserId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return Text(
                    'Cargando...',
                    style: TextStyle(color: Colors.white),
                  );
                }
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final otherUserName = userData['name'] ?? 'Usuario';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUserName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Online ahora',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call, color: Colors.white),
            onPressed: () {
              // Acción futura para videollamada
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('chatId', isEqualTo: chatId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar mensajes',
                      style: TextStyle(color: Color(0xFF8A8D91)),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay mensajes aún',
                      style: TextStyle(color: Color(0xFF8A8D91)),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Color(0xFF0B2545) : Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isMe ? 10 : 0),
                            topRight: Radius.circular(isMe ? 0 : 10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['text'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Color(0xFF0B2545),
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              _formatTimestamp(
                                  message['createdAt'] as Timestamp?),
                              style: TextStyle(
                                color:
                                    isMe ? Colors.grey[400] : Color(0xFF8A8D91),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final time = TimeOfDay.fromDateTime(date);
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageInput(BuildContext context) {
    final _messageController = TextEditingController();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFF0B2545)),
            onPressed: () {
              // Acción futura para el botón de "Más"
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFF3F4F6),
                hintText: 'Escribe un mensaje...',
                hintStyle: TextStyle(color: Color(0xFF8A8D91)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final text = _messageController.text.trim();
              if (text.isEmpty) return;

              final currentUserId = FirebaseAuth.instance.currentUser!.uid;

              try {
                // Añadir mensaje a la colección 'messages'
                await FirebaseFirestore.instance.collection('messages').add({
                  'chatId': chatId,
                  'senderId': currentUserId,
                  'text': text,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                // Actualizar el último mensaje en la colección 'chats'
                await FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .update({
                  'lastMessage': text,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                _messageController.clear();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al enviar mensaje: $e')),
                );
              }
            },
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFF0B2545),
              child: Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
