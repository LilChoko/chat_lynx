import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// Registro de usuario
  Future<bool> register(String email, String password, String name) async {
    try {
      // Registrar al usuario en Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar los datos del usuario en Firestore
      final user = userCredential.user!;
      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'name': name,
        'email': email,
        'phoneNumber': '', // Inicializa con un campo vacío para el teléfono
        'profilePicture':
            '', // Puedes agregar funcionalidad de subir imagen más adelante
      });

      return true;
    } catch (e) {
      print('Error en el registro: $e');
      return false;
    }
  }

  /// Verificación y redirección después del inicio de sesión
  Future<void> handlePostLogin(BuildContext context) async {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      // Verificar si el usuario tiene un número de teléfono registrado
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null &&
            (userData['phoneNumber'] == null ||
                userData['phoneNumber'].isEmpty)) {
          // Si no hay número de teléfono, redirigir a la pantalla PhoneNumberScreen
          Navigator.pushReplacementNamed(context, '/phoneNumber');
        } else {
          // Si ya tiene un número registrado, redirigir a ChatListScreen
          Navigator.pushReplacementNamed(context, '/chatList');
        }
      } else {
        // Si el documento no existe, crear uno y redirigir a PhoneNumberScreen
        await _firestore.collection('users').doc(currentUser.uid).set({
          'id': currentUser.uid,
          'name': currentUser.displayName ?? 'Sin Nombre',
          'email': currentUser.email ?? 'Sin Correo',
          'phoneNumber': '',
        });
        Navigator.pushReplacementNamed(context, '/phoneNumber');
      }
    } else {
      // Si no hay usuario autenticado, redirigir al LoginScreen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// Inicio de sesión
  Future<bool> login(
      String email, String password, BuildContext context) async {
    try {
      // Iniciar sesión con Firebase Authentication
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Manejar el flujo de navegación después del inicio de sesión
      await handlePostLogin(context);

      return true;
    } catch (e) {
      print('Error en el inicio de sesión: $e');
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
