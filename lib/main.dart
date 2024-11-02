import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/image_gallery_screen.dart';
import 'screens/profile_screen.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

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
      home: LoginScreen(),
      routes: {
        '/signup': (context) => SignupScreen(), // Defina a rota para a tela de cadastro
        '/home': (context) => HomeScreen(), // Rota para Home_Screen
        '/gallery': (context) => ImageGalleryScreen(), // Rota para Galeria
        "/profile": (context) => ProfileScreen(), // Rota para o perfil de usuario.
      },
    );
  }
}
