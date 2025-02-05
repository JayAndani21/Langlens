import 'package:flutter/material.dart';
import '../pages/translation_page.dart';

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
            _buildActionButtons(context), // Pass context to buttons
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
          Icons.camera_alt_outlined, 
          'Capture Image',
          () => _navigateToCapture(context)
        ),
        const SizedBox(height: 15),
        _customButton(
          Icons.upload_outlined, 
          'Upload Image', 
          () => _navigateToUpload(context)
        ),
        const SizedBox(height: 15),
        _customButton(
          Icons.translate, 
          'Text Translation', 
          () => _navigateToTranslation(context),
        ),
      ],
    );
  }

  Widget _customButton(IconData icon, String text, VoidCallback onPressed) {
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
        onPressed: onPressed, // Pass the navigation function here
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

  // Navigation Functions
  void _navigateToCapture(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const CaptureScreen()), 
  );
}


  void _navigateToUpload(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UploadScreen()),
    );
  }

  void _navigateToTranslation(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const TranslationPage()), // Ensure it's a StatefulWidget
  );
}

}


// Dummy Screens (Replace with actual screens)
class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Capture Image")),
      body: Center(child: Text("Camera functionality here")),
    );
  }
}

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Image")),
      body: Center(child: Text("Upload functionality here")),
    );
  }
}