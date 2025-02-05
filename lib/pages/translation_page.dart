import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color darkBlue = Color(0xFF1976D2);
  static const Color lightPurple = Color(0xFFFAF4FC);
}

class _TranslationPageState extends State<TranslationPage> {
  String _sourceLang = 'English';
  String _targetLang = 'Gujarati';
  final TextEditingController _sourceController = TextEditingController();
  final FocusNode _sourceFocus = FocusNode();
  String _translatedText = '';

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });
  }

  void _translateText() {
    setState(() {
      _translatedText = _sourceController.text; // Temporary mock translation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLanguageSelector(),
            const SizedBox(height: 24),
            _buildSourceTextField(),
            const SizedBox(height: 24),
            _buildTranslatedText(),
            const Spacer(),
            _buildTranslateButton(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'LangLens',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLanguageChip(_sourceLang, true),
          IconButton(
            icon: const Icon(Icons.swap_horiz, size: 32),
            onPressed: _swapLanguages,
          ),
          _buildLanguageChip(_targetLang, false),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String language, bool isSource) {
    return GestureDetector(
      onTap: () {
        _showLanguageSelectionDialog(isSource);
      },
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/flags/${_getFlagCode(language)}.svg',
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 8),
          Text(
            language,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Icon(Icons.arrow_drop_down, size: 24),
        ],
      ),
    );
  }

  void _showLanguageSelectionDialog(bool isSource) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('English', isSource),
              _buildLanguageOption('Gujarati', isSource),
              _buildLanguageOption('Hindi', isSource),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, bool isSource) {
    return ListTile(
      title: Text(language),
      onTap: () {
        setState(() {
          if (isSource) {
            _sourceLang = language;
          } else {
            _targetLang = language;
          }
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSourceTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _sourceLang,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightPurple,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _sourceController,
            focusNode: _sourceFocus,
            maxLines: 4,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter text to translate',
              suffixIcon: _sourceFocus.hasFocus
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _sourceController.clear(),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTranslatedText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _targetLang,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.lightPurple,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Text(
            _translatedText,
            style: GoogleFonts.poppins(
              color: AppColors.black,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTranslateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _translateText,
        child: Text(
          'Translate',
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _getFlagCode(String language) {
    switch (language) {
      case 'English':
        return 'us';
      case 'Gujarati':
        return 'in';
      case 'Hindi':
        return 'in';
      case 'French':
        return 'fr';
      case 'Spanish':
        return 'es';
      default:
        return 'us';
    }
  }
}
