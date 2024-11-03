import 'dart:io'; // Para manipulação de diretório e arquivos
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Para acessar diretórios do dispositivo

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<File> _recentImages = [];

  @override
  void initState() {
    super.initState();
    _loadRecentImages();
  }

  // Função para carregar as últimas três imagens do diretório 'results'
  Future<void> _loadRecentImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final resultsDir = Directory('${directory.path}/results');

    if (!await resultsDir.exists()) {
    await resultsDir.create(recursive: true);
  }

  // Suponha que temos uma imagem processada como File
  final processedImage = File('${resultsDir.path}/processed_image_${DateTime.now().millisecondsSinceEpoch}.png');
  
  // Salva a imagem (no exemplo, substitua isso pela lógica do processamento real)
  await processedImage.writeAsBytes([]); // Aqui você colocaria os bytes reais da imagem

  // Recarrega as imagens para exibir na tela
  _loadRecentImages();
}

  // Verifica se o arquivo é uma imagem
  bool _isImage(String path) {
    final extensions = ['.jpg', '.jpeg', '.png'];
    return extensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  // Simulação de captura de imagem (pode ser substituído por lógica de câmera)
  Future<void> _pickImage() async {
    // Lógica futura para capturar imagem e salvar em 'results'
    print('Capturar imagem...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _recentImages.isEmpty
            ? Center(child: Text('Nenhuma imagem encontrada.'))
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount: _recentImages.length,
          itemBuilder: (context, index) {
            return Image.file(
              _recentImages[index],
              fit: BoxFit.cover,
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                icon: Icon(Icons.photo, color: Colors.green),
                onPressed: () {
                  Navigator.pushNamed(context, '/gallery');
                }
            ),
            IconButton(
              icon: Icon(Icons.home, color: Colors.green),
              onPressed: () { Navigator.pushNamed(context, '/home');
              }, // Navega para Home
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.green),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _pickImage,
        child: Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
