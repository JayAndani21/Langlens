import 'dart:io'; // Add this import for File class
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'translation_page.dart'; // Import your friend's translation page

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            onPressed: () {},
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
          onPressed: () => _handleCameraAction(context),
        ),
        const SizedBox(height: 15),
        _customButton(
          icon: Icons.upload_outlined,
          text: 'Upload Image',
          onPressed: () => _handleUploadAction(context),
        ),
        const SizedBox(height: 15),
        _customButton(
          icon: Icons.translate,
          text: 'Text Translation',
          onPressed: () => _navigateToTranslation(context),
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
            const SnackBar(
              content: Text('Camera permission is required'),
              duration: Duration(seconds: 2),
            ),
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
        // Navigate to capture screen with the captured image
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CaptureScreen(imagePath: imageFile.path),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
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
        // Navigate to upload screen with selected image
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadScreen(imagePath: imageFile.path),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
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

// Updated Capture Screen with image display
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
              onPressed: () {
                // Add OCR processing here
              },
              child: const Text('Process Text'),
            ),
          ],
        ),
      ),
    );
  }
}

// Updated Upload Screen with image display
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
            Image.file(File(imagePath)
            ,height:650,
            width: 700,
            ), // Display the uploaded image
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add processing logic here
              },
              child: Text('Process Image'),
            ),
          ],
        ),
      ),
    );
  }
}