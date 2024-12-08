import 'package:chat_lynx/providers/chat_provider.dart';
import 'package:chat_lynx/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/chat_list_screen.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Inicializar servicios antes de runApp

  // Inicializar Supabase con las constantes
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Chat App',
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/chatList': (context) => ChatListScreen(),
          '/register': (context) => RegisterScreen(), // Ruta para registro
        },
      ),
    );
  }
}
