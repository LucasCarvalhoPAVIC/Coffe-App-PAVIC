import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar o Firebase Auth

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/image_gallery_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await Firebase.initializeApp();

  // Create image directory before running the app
  final directory = await getApplicationDocumentsDirectory();
  final imageDirectoryPath = '${directory.path}/images';
  final imageDirectory = Directory(imageDirectoryPath);

  if (!await imageDirectory.exists()) {
    await imageDirectory.create(recursive: true);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // Monitorar mudanças de autenticação
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final User? user = snapshot.data;
            if (user != null) {
              // Se o usuário está autenticado, ir para a HomeScreen
              return HomeScreen();
            }
            // Se o usuário não está autenticado, mostrar a LoginScreen
            return LoginScreen();
          }
          // Enquanto a conexão está sendo estabelecida, você pode mostrar um carregamento
          return Center(child: CircularProgressIndicator());
        },
      ),
      routes: {
        '/signup': (context) => SignupScreen(), // Defina a rota para a tela de cadastro
        '/gallery': (context) => ImageGalleryScreen(), // Rota para Galeria
        "/profile": (context) => ProfileScreen(), // Rota para o perfil de usuario.
      },
    );
  }
}
