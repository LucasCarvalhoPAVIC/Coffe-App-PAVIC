import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ImageGalleryScreen extends StatefulWidget {
  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  File? _selectedImage;
  String? _currentDiagnosis;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDirectoryPath = '${directory.path}/images';
    final imageDirectory = Directory(imageDirectoryPath);

    if (await imageDirectory.exists()) {
      setState(() {
        _images = imageDirectory
            .listSync()
            .where((file) => file.path.endsWith('.jpg') || file.path.endsWith('.png'))
            .map((file) => File(file.path))
            .toList();
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final savedImage = await _saveImage(File(pickedFile.path));
      setState(() {
        _images.add(savedImage);
        _selectedImage = savedImage; // Define a imagem selecionada
      });
    }
  }

  Future<void> _importImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final savedImage = await _saveImage(File(pickedFile.path));
      setState(() {
        _images.add(savedImage);
        _selectedImage = savedImage; // Define a imagem selecionada
      });
    }
  }

  Future<File> _saveImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDirectoryPath = '${directory.path}/images';
    final imageDirectory = Directory(imageDirectoryPath);

    if (!(await imageDirectory.exists())) {
      await imageDirectory.create(recursive: true);
    }

    final fileName = path.basename(image.path);
    final savedImagePath = '$imageDirectoryPath/$fileName';
    return image.copy(savedImagePath);
  }

  Future<void> _sendImageToServer() async {
    if (_selectedImage == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.0.31:5000/diagnose'), // URL do servidor
    );
    request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      setState(() {
        _currentDiagnosis = json.decode(responseData)['diagnosis'];
      });
      _showDiagnosisDialog(_currentDiagnosis);
    } else {
      _showDiagnosisDialog('Erro ao processar a imagem.');
    }
  }

  void _showDiagnosisDialog(String? diagnosis) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Diagnóstico'),
          content: Text(diagnosis ?? 'Erro ao processar a imagem.'),
          actions: <Widget>[
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSelectedImage() async {
    if (_selectedImage != null) {
      await _selectedImage!.delete();
      setState(() {
        _images.remove(_selectedImage);
        _selectedImage = null; // Reseta a imagem selecionada após a exclusão
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnóstico de Folhas'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _importImage, // Botão para importar imagem
                  child: Text('Importar'),
                ),
                ElevatedButton(
                  onPressed: _deleteSelectedImage, // Botão para deletar imagem selecionada
                  child: Text('Deletar'),
                ),
                ElevatedButton(
                  onPressed: _sendImageToServer, // Botão para enviar imagem selecionada
                  child: Text('Enviar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final image = _images[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImage = image; // Define a imagem selecionada ao tocar
                    });
                  },
                  child: Stack(
                    children: [
                      Image.file(
                        image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      if (_selectedImage == image) // Verifica se a imagem está selecionada
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent, width: 3), // Borda azul para a imagem selecionada
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
