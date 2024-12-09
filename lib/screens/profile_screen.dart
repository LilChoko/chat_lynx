import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6), // Fondo claro
      appBar: AppBar(
        backgroundColor: Color(0xFF0B2545), // Azul oscuro
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Colors.white), // Flecha hacia atrás
          onPressed: () {
            Navigator.pushReplacementNamed(
                context, '/chatList'); // Ir a ChatListScreen
          },
        ),
        title: Text(
          'Perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'No se pudo cargar el perfil.',
                style: TextStyle(color: Color(0xFF8A8D91), fontSize: 18),
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Cabecera ajustada
                Container(
                  width: double.infinity, // Ancho completo
                  padding:
                      EdgeInsets.symmetric(vertical: 40), // Margen vertical
                  decoration: BoxDecoration(
                    color: Color(0xFF0B2545), // Azul oscuro
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          userData['name'][0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B2545), // Azul oscuro
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        userData['name'] ?? 'Sin nombre',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        userData['email'] ?? 'Sin correo',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFE0E0E0), // Gris claro
                        ),
                      ),
                    ],
                  ),
                ),
                // Información detallada
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Campo de nombre
                      ListTile(
                        leading: Icon(Icons.person, color: Color(0xFF0B2545)),
                        title: Text(
                          'Nombre',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8A8D91),
                          ),
                        ),
                        subtitle: Text(
                          userData['name'] ?? 'Sin nombre',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0B2545),
                          ),
                        ),
                      ),
                      Divider(),
                      // Campo de correo
                      ListTile(
                        leading: Icon(Icons.email, color: Color(0xFF0B2545)),
                        title: Text(
                          'Correo Electrónico',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8A8D91),
                          ),
                        ),
                        subtitle: Text(
                          userData['email'] ?? 'Sin correo',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0B2545),
                          ),
                        ),
                      ),
                      Divider(),
                      // Campo de teléfono
                      ListTile(
                        leading: Icon(Icons.phone, color: Color(0xFF0B2545)),
                        title: Text(
                          'Número de Teléfono',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8A8D91),
                          ),
                        ),
                        subtitle: Text(
                          userData['phoneNumber'] ?? 'Sin número',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0B2545),
                          ),
                        ),
                      ),
                      Divider(),
                      SizedBox(height: 155),
                      // Botón de cerrar sesión más grande
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0B2545),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          minimumSize:
                              Size(double.infinity, 50), // Botón grande
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Cerrar sesión',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
