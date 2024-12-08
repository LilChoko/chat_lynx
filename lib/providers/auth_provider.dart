import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _isAuthenticated = false;
    notifyListeners();
  }
}
