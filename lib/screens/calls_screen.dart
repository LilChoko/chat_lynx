import 'package:flutter/material.dart';

class CallsScreen extends StatefulWidget {
  @override
  _CallsScreenState createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  int _selectedIndex = 0; // Índice para la pestaña "Llamadas"

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navegación entre las pestañas
    switch (index) {
      case 0:
        // Ya estamos en Llamadas
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/chatList'); // Navegar a Chats
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile'); // Navegar a Perfil
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0B2545),
        elevation: 0,
        title: Text(
          'Llamadas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call_rounded, color: Colors.white),
            onPressed: () {
              // Acción para agregar una nueva llamada
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 6, // Número de llamadas de ejemplo
        itemBuilder: (context, index) {
          final callName = [
            "Larry Marshall",
            "Julie Alvarado",
            "Beatrice Wagner",
            "Francine Boyd",
            "Randy Young",
            "Frank Lee"
          ][index];
          final callTime = [
            "now",
            "3 min ago",
            "20 min ago",
            "2 hours ago",
            "3 days ago",
            "3 days ago"
          ][index];
          final callIcon = [
            Icons.call_received,
            Icons.call_made,
            Icons.call_received,
            Icons.call_made,
            Icons.call_received,
            Icons.call_received,
          ][index];
          final callColor = [
            Colors.red,
            Colors.green,
            Colors.red,
            Colors.green,
            Colors.red,
            Colors.red,
          ][index];

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/lincito.png'),
              radius: 25,
            ),
            title: Text(
              callName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B2545),
              ),
            ),
            subtitle: Text(
              callTime,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8A8D91),
              ),
            ),
            trailing: Icon(
              callIcon,
              color: callColor,
            ),
            onTap: () {
              // Acción al tocar un historial de llamada
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Color(0xFF0B2545),
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFF8A8D91),
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.video_call_rounded),
              label: 'Llamadas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_rounded),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
