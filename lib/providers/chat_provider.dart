import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _chats = [];

  List<Map<String, dynamic>> get chats => _chats;

  Future<void> fetchChats(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      _chats = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error al obtener chats: $e');
    }
  }

  Future<void> createChat(String chatName, String userId) async {
    try {
      final chatRef = await _firestore.collection('chats').add({
        'name': chatName,
        'participants': [userId],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('messages').add({
        'chatId': chatRef.id,
        'text': '¡Chat creado!',
        'senderId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await fetchChats(userId);
    } catch (e) {
      print('Error al crear el chat: $e');
    }
  }
}
