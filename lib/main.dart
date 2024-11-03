import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/image_gallery_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o Flutter esteja inicializado
  await Firebase.initializeApp();

  // Cria o diretório de imagens antes de executar o app
  final directory = await getApplicationDocumentsDirectory();
  final imageDirectoryPath = '${directory.path}/images';
  final imageDirectory = Directory(imageDirectoryPath);

  if (!await imageDirectory.exists()) {
    await imageDirectory.create(recursive: true);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Altera para iniciar na tela de login
      routes: {
        '/login': (context) => const LoginScreen(), // Rota para a tela de login
        '/signup': (context) => const SignupScreen(), // Rota para a tela de cadastro
        '/home': (context) => const HomeScreen(), // Rota para HomeScreen
        '/gallery': (context) => const ImageGalleryScreen(), // Rota para Galeria
        '/profile': (context) => const ProfileScreen(), // Rota para o perfil de usuário
      },
      onUnknownRoute: (settings) {
        // Rota padrão se a rota não for encontrada
        return MaterialPageRoute(builder: (context) => const LoginScreen()); // Redireciona para a tela de login
      },
    );
  }
}
