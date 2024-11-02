import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({super.key});

  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  List<File> _images = [];
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

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
      });
    }
  }

  Future<void> _importImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final savedImage = await _saveImage(File(pickedFile.path));
      setState(() {
        _images.add(savedImage);
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

  void _toggleSelection(File image, {bool longPress = false}) {
    setState(() {
      if (_selectedImages.isEmpty) {
        if (longPress) {
          _selectedImages.add(image);
        } else {
          _showExpandedImage(image);
        }
      } else {
        if (_selectedImages.contains(image)) {
          _selectedImages.remove(image);
        } else {
          _selectedImages.add(image);
        }
      }
    });
  }

  void _showExpandedImage(File image) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Image.file(image, fit: BoxFit.contain),
        ),
      ),
    );
  }

  void _deleteSelectedImages() async {
    if (_selectedImages.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deletando ${_selectedImages.length} imagens...'),
          duration: Duration(seconds: 1),
        ),
      );

      for (var image in _selectedImages) {
        await image.delete();
        _images.remove(image);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedImages.length} imagens deletadas com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        _selectedImages.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nenhuma imagem selecionada.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _sendSelectedImages() async {
    if (_selectedImages.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enviando ${_selectedImages.length} imagens...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Process images here (e.g., using ImageProcessor)

      setState(() {
        _selectedImages.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nenhuma imagem selecionada.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          children: [
            Image.asset(
              "assets/logo1.png",
              height: 24,
            ),
            Text(
              "Galeria",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [SizedBox(width: 36)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _importImage,
                  child: Text('Importar'),
                ),
                ElevatedButton(
                  onPressed: _deleteSelectedImages,
                  child: Text('Deletar'),
                ),
                ElevatedButton(
                  onPressed: _sendSelectedImages,
                  child: Text('Enviar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
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
                  final isSelected = _selectedImages.contains(image);

                  return GestureDetector(
                    onTap: () => _toggleSelection(image),
                    onLongPress: () => _toggleSelection(image, longPress: true),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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
              },
            ),
            IconButton(
              icon: Icon(Icons.home, color: Colors.green),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
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
