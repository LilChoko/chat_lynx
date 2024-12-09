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

  Future<void> createChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  }) async {
    try {
      // Generar un ID único para el chat
      final chatRef = _firestore.collection('chats').doc();

      await chatRef.set({
        'participants': [currentUserId, otherUserId],
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
        'userNames': {
          currentUserId: currentUserName,
          otherUserId: otherUserName,
        },
      });
    } catch (e) {
      print('Error al crear el chat: $e');
    }
  }
}
