import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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
          onPressed: () => _handleTextTranslation(context),
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
        // TODO: Add your OCR processing logic here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Captured image: ${imageFile.path}'),
            duration: const Duration(seconds: 2),
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
    // TODO: Implement upload functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Upload functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleTextTranslation(BuildContext context) async {
    // TODO: Implement text translation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text translation coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}