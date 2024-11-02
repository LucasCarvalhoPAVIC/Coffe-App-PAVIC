import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class Box extends StatelessWidget {
  final String _phoneController = "68 99210-4525";

  const Box({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        _phoneController,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    );
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Controladores para os campos de texto
  final TextEditingController _phoneController = TextEditingController(text: "68 99210-4525");
  final TextEditingController _emailController = TextEditingController(text: "Lucas@gmail.com");
  final TextEditingController _cpfController = TextEditingController(text: "000.000.000-00");

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<File> _saveProfileImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/profile_image.jpg';
    return image.copy(imagePath);
  }

  void _updateProfile() {
    // Aqui você pode implementar a lógica para salvar as informações
    print('Telefone: ${_phoneController.text}');
    print('E-mail: ${_emailController.text}');
    print('CPF: ${_cpfController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/logo1.png', height: 40),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            // Imagem de perfil circular
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? Icon(Icons.camera_alt, size: 40, color: Colors.white70)
                    : null,
              ),
            ),
            SizedBox(height: 16),
            // Nome do usuário
            Text(
              'Ruiz Marccos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            // Campo de telefone
            _buildTextField("Telefone", _phoneController),
            SizedBox(height: 12),
            // Campo de e-mail
            _buildTextField("E-mail", _emailController),
            SizedBox(height: 12),
            // Campo de CPF
            _buildTextField("CPF", _cpfController),
            SizedBox(height: 24),
            // Botão para atualizar dados
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text('Atualizar dados'),
            ),
          ],
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
              onPressed: () => Navigator.pushNamed(context, '/gallery'),
            ),
            IconButton(
              icon: Icon(Icons.home, color: Colors.green),
              onPressed: () => Navigator.pushNamed(context, '/home'),
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.green),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _pickImage(ImageSource.camera),
        child: Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Widget para construir campos de texto reutilizáveis
  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exibe o valor da label acima do TextField
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8), // Espaçamento entre o rótulo e o campo de texto
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
