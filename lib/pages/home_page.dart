import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/ocr_service.dart';
import 'login_page.dart';
import 'ocr_processing_screen.dart';
import 'profile_page.dart';
import 'translation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required Null Function() onLoginSuccess});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String? _token;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<FeatureItem> _features = [
    FeatureItem(
      title: 'Image to Text',
      description: 'Extract text from images',
      icon: Icons.image_search,
      gradient: const LinearGradient(
        colors: [Color(0xFF6448FE), Color(0xFF5FC6FF)],
      ),
    ),
    FeatureItem(
      title: 'Translation',
      description: 'Translate between languages',
      icon: Icons.translate,
      gradient: const LinearGradient(
        colors: [Color(0xFFFF9D6C), Color(0xFFBB4E75)],
      ),
    ),
    FeatureItem(
      title: 'Document Scan',
      description: 'Digitize your documents',
      icon: Icons.document_scanner,
      gradient: const LinearGradient(
        colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadToken();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  void _checkLogin(BuildContext context, VoidCallback onSuccess) {
    if (_token != null) {
      onSuccess();
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: LoginPage(
            onLoginSuccess: () async {
              await _loadToken();
              if (mounted) {
                setState(() {});
                Navigator.pop(context);
              }
            },
          ),
        ),
      );
    }
  }

  Future<void> _handleImageAction(bool isCamera) async {
    try {
      if (isCamera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) return;
      }

      final image = await Provider.of<OCRService>(context, listen: false)
          .pickImage(isCamera);
          
      if (image != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OcrProcessingScreen(imageFile: image),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade100,
                      ),
                      child: const Icon(Icons.translate, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'LangLens',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                actions: [
                  GestureDetector(
                    onTap: () => _checkLogin(context, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildHeroSection(size),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'What would you like to do today?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureCards(),
                      const SizedBox(height: 30),
                      _buildQuickActionsSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _checkLogin(context, () => _handleImageAction(true)),
        backgroundColor: Colors.blue.shade700,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Instant Scan'),
      ),
    );
  }

  Widget _buildHeroSection(Size size) {
    return Container(
      height: size.height * 0.25,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade700, Colors.purple.shade700],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.2,
              child: Icon(
                Icons.language,
                size: 150,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Translate Anything',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Capture, extract, and translate text from images in real-time',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildHeroButton(
                      icon: Icons.camera_alt,
                      text: 'Camera',
                      onTap: () => _checkLogin(context, () => _handleImageAction(true)),
                    ),
                    const SizedBox(width: 16),
                    _buildHeroButton(
                      icon: Icons.photo_library,
                      text: 'Gallery',
                      onTap: () => _checkLogin(context, () => _handleImageAction(false)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCards() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _features.length,
        itemBuilder: (context, index) {
          final item = _features[index];
          return Container(
            width: 160,
            margin: EdgeInsets.only(
              right: index == _features.length - 1 ? 0 : 16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: item.gradient,
              boxShadow: [
                BoxShadow(
                  color: item.gradient.colors.first.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _checkLogin(context, () {
                    if (index == 0) {
                      _handleImageAction(false);
                    } else if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TranslationPage(initialText: ''),
                        ),
                      );
                    } else if (index == 2) {
                      _handleImageAction(true);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.icon,
                        color: Colors.white,
                        size: 36,
                      ),
                      const Spacer(),
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActionTile(
                icon: Icons.camera_alt,
                color: Colors.green,
                title: 'Capture Image',
                subtitle: 'Use camera to scan text',
                onTap: () => _checkLogin(context, () => _handleImageAction(true)),
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.upload_file,
                color: Colors.orange,
                title: 'Upload Image',
                subtitle: 'Select from gallery',
                onTap: () => _checkLogin(context, () => _handleImageAction(false)),
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.text_fields,
                color: Colors.purple,
                title: 'Manual Text',
                subtitle: 'Type or paste text to translate',
                onTap: () => _checkLogin(context, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TranslationPage(initialText: ''),
                    ),
                  );
                }),
              ),
              ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.black54,
          fontSize: 14,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
      onTap: onTap,
    );
  }
}

class FeatureItem {
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;

  FeatureItem({
    required this.title, 
    required this.description, 
    required this.icon, 
    required this.gradient,
  });
}