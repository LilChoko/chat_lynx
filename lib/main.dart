import 'package:chat_lynx/screens/chat_detail_screen.dart';
import 'package:chat_lynx/screens/contacts_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:chat_lynx/providers/auth_provider.dart' as local;
import 'providers/chat_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/chat_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => local.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Chat App',
        initialRoute: '/login', // Siempre inicia en la pantalla de login
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/chatList': (context) => ChatListScreen(),
          '/contacts': (context) => ContactsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/chatDetail') {
            final chatId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ChatDetailScreen(chatId: chatId),
            );
          }
          return null;
        },
      ),
    );
  }
}
