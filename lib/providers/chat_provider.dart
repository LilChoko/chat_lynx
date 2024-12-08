import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> _messages = [];

  List<Map<String, dynamic>> get chats => _chats;
  List<Map<String, dynamic>> get messages => _messages;

  Future<void> fetchChats() async {
    final response = await _supabase
        .from('chats')
        .select()
        .order('created_at', ascending: false);

    _chats = List<Map<String, dynamic>>.from(response);
    notifyListeners();
  }

  Future<void> fetchMessages(String chatId) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);

    _messages = List<Map<String, dynamic>>.from(response);
    notifyListeners();
  }

  Future<void> sendMessage(String chatId, String content) async {
    await _supabase.from('messages').insert({
      'chat_id': chatId,
      'sender_id': _supabase.auth.currentUser!.id,
      'content': content,
    });

    await fetchMessages(
        chatId); // Recarga los mensajes después de enviar uno nuevo
  }
}
