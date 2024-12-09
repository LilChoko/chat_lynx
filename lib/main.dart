import 'package:chat_lynx/screens/chat_detail_screen.dart';
import 'package:chat_lynx/screens/contacts_screen.dart';
import 'package:chat_lynx/screens/phone_screen.dart';
import 'package:chat_lynx/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:chat_lynx/providers/auth_provider.dart' as local;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/chat_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/chat_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inicializa Supabase
  await Supabase.initialize(
    url: 'https://sjzkukvusacvnseomnjo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqemt1a3Z1c2Fjdm5zZW9tbmpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM2MDMwMTcsImV4cCI6MjA0OTE3OTAxN30.L0WFe80buks4HQxDUt7-BbVI32jEXDHqkzDyDqjrXFg',
  );

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
        debugShowCheckedModeBanner: false,
        title: 'Chat App',
        initialRoute: '/',
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/phoneNumber': (context) => PhoneNumberScreen(),
          '/chatList': (context) => ChatListScreen(),
          '/contacts': (context) => ContactsScreen(),
          '/profile': (context) => ProfileScreen(),
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
        home: _getInitialScreen(),
      ),
    );
  }

  Widget _getInitialScreen() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return LoginScreen();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return LoginScreen();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final hasPhoneNumber = userData['phoneNumber'] != null &&
            userData['phoneNumber'].isNotEmpty;

        if (!hasPhoneNumber) {
          return PhoneNumberScreen();
        }

        return ChatListScreen();
      },
    );
  }
}
