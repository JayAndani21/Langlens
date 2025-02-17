import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'auth_service.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _name;
  String? _email;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadThemePreference();
  }

Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _name = prefs.getString('name') ?? 'No Name';
        _email = prefs.getString('email') ?? 'No Email';
      });
      // For debugging
      print('Loaded Data: $_name, $_email');
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
    });
    await prefs.setBool('isDarkMode', value);
  }

  Future<void> _logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(onLoginSuccess: () {}),
      ),
    );
  }

  Color get _backgroundColor => _isDarkMode ? Colors.grey[900]! : Colors.white;
  Color get _textColor => _isDarkMode ? Colors.white : Colors.black;
  Color get _cardColor => _isDarkMode ? Colors.grey[800]! : Colors.grey[50]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isDarkMode
                        ? [Colors.grey[800]!, Colors.grey[700]!]
                        : [Colors.blue, Colors.lightBlue],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 80, left: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: _isDarkMode ? Colors.white : Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _name ?? 'Loading...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _email ?? 'Loading...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () => _toggleTheme(!_isDarkMode),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSection(
                    title: 'Account Management',
                    child: Column(
                      children: [
                        _buildAccountOption(
                          icon: Icons.email,
                          title: 'Change Email',
                          onTap: () {},
                        ),
                        _buildAccountOption(
                          icon: Icons.lock,
                          title: 'Change Password',
                          onTap: () {},
                        ),
                        _buildAccountOption(
                          icon: Icons.delete,
                          title: 'Delete Account',
                          onTap: () {},
                        ),
                        _buildAccountOption(
                          icon: Icons.logout,
                          title: 'Logout',
                          onTap: () => _logout(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: 'Quick Actions',
                    child: Column(
                      children: [
                        _buildQuickAction(
                          icon: Icons.language,
                          title: 'Language Preferences',
                          onTap: () {
                            // Add navigation later when page is created
                          },
                        ),
                        _buildQuickAction(
                          icon: Icons.history,
                          title: 'Translation History',
                          onTap: () {
                            // Add navigation later when page is created
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      color: _cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: _textColor),
      title: Text(
        title,
        style: TextStyle(
          color: _textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, 
                    size: 16, 
                    color: _textColor.withOpacity(0.6)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.blue[800] : Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _isDarkMode ? Colors.white : Colors.blue[900]),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, 
                    size: 16, 
                    color: _textColor.withOpacity(0.6)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}