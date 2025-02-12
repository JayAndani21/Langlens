import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'login_page.dart';
import 'translation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoggedIn = false; // Track login state

  void _handleLoginSuccess() {
    setState(() {
      _isLoggedIn = true; // User is now logged in
    });
  }

  void _checkLogin(BuildContext context, VoidCallback onSuccess) {
    if (_isLoggedIn) {
      onSuccess(); // Proceed if logged in
    } else {
      // Show message and redirect to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first!')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(onLoginSuccess: _handleLoginSuccess),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LangLens',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(onLoginSuccess: _handleLoginSuccess),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBannerSection(),
            const SizedBox(height: 30),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/images/banner_image.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _customButton(
          icon: Icons.camera_alt_outlined,
          text: 'Capture Image',
          onPressed: () => _checkLogin(context, () => _handleCameraAction(context)),
        ),
        const SizedBox(height: 15),
        _customButton(
          icon: Icons.upload_outlined,
          text: 'Upload Image',
          onPressed: () => _checkLogin(context, () => _handleUploadAction(context)),
        ),
        const SizedBox(height: 15),
        _customButton(
          icon: Icons.translate,
          text: 'Text Translation',
          onPressed: () => _checkLogin(context, () => _navigateToTranslation(context)),
        ),
      ],
    );
  }

  Widget _customButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCameraAction(BuildContext context) async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission is required')),
          );
        }
        return;
      }

      final imageFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (imageFile != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CaptureScreen(imagePath: imageFile.path)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleUploadAction(BuildContext context) async {
    try {
      final imageFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imageFile != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UploadScreen(imagePath: imageFile.path)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateToTranslation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TranslationPage()),
    );
  }
}

class CaptureScreen extends StatelessWidget {
  final String imagePath;
  const CaptureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Captured Image")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(File(imagePath)), // Display the captured image
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Process Text'),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadScreen extends StatelessWidget {
  final String imagePath;
  const UploadScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Uploaded Image")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(
              File(imagePath),
              height: 650,
              width: 700,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Process Image'),
            ),
          ],
        ),
      ),
    );
  }
}
