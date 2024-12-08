import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _chats = [];

  List<Map<String, dynamic>> get chats => _chats;

  /// Obtiene los chats del usuario autenticado
  Future<void> fetchChats() async {
    try {
      final userId =
          _supabase.auth.currentUser!.id; // ID del usuario autenticado
      print('Iniciando consulta a la tabla chats para el usuario: $userId...');
      final response = await _supabase
          .from('chats')
          .select()
          .eq('user_id', userId) // Filtra por el usuario autenticado
          .order('created_at', ascending: false);

      if (response is List<dynamic>) {
        _chats = List<Map<String, dynamic>>.from(response);
        print('Datos obtenidos de Supabase: $_chats');
      } else {
        _chats = [];
      }
    } catch (e) {
      print('Error al obtener chats: $e');
      _chats = [];
    }
    notifyListeners(); // Notifica cambios al UI
  }

  /// Crea un nuevo chat asociado al usuario autenticado
  Future<void> createChat(String chatName) async {
    try {
      final userId =
          _supabase.auth.currentUser!.id; // ID del usuario autenticado
      await _supabase.from('chats').insert({
        'name': chatName,
        'user_id': userId, // Asigna el chat al usuario autenticado
        'created_at': DateTime.now().toIso8601String(),
      });
      await fetchChats(); // Refresca la lista de chats
    } catch (e) {
      print('Error al crear el chat: $e');
    }
  }
}
