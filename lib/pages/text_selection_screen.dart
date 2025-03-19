import 'package:flutter/material.dart';
import 'translation_page.dart';
import 'text_selection_card.dart';

class TextSelectionScreen extends StatefulWidget {
  final List<String> textBlocks;
  
  const TextSelectionScreen({
    Key? key,
    required this.textBlocks,
  }) : super(key: key);

  @override
  State<TextSelectionScreen> createState() => _TextSelectionScreenState();
}

class _TextSelectionScreenState extends State<TextSelectionScreen> {
  List<bool> _selectedBlocks = [];
  String _selectedText = '';

  @override
  void initState() {
    super.initState();
    _selectedBlocks = List.generate(widget.textBlocks.length, (_) => false);
  }

  void _toggleSelection(int index) {
    setState(() {
      _selectedBlocks[index] = !_selectedBlocks[index];
      _updateSelectedText();
    });
  }

  void _updateSelectedText() {
    List<String> selectedTexts = [];
    for (int i = 0; i < widget.textBlocks.length; i++) {
      if (_selectedBlocks[i]) {
        selectedTexts.add(widget.textBlocks[i]);
      }
    }
    _selectedText = selectedTexts.join(' ');
  }

  void _selectAll() {
    setState(() {
      _selectedBlocks = List.generate(widget.textBlocks.length, (_) => true);
      _updateSelectedText();
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedBlocks = List.generate(widget.textBlocks.length, (_) => false);
      _selectedText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Text'),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: _selectAll,
            tooltip: 'Select All',
          ),
          IconButton(
            icon: const Icon(Icons.deselect),
            onPressed: _deselectAll,
            tooltip: 'Deselect All',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.textBlocks.length,
              itemBuilder: (context, index) {
                return TextSelectionCard(
                  text: widget.textBlocks[index],
                  isSelected: _selectedBlocks[index],
                  onToggle: () => _toggleSelection(index),
                );
              },
            ),
          ),
          
          // Selected text preview
          if (_selectedText.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Text:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          
          // Bottom action button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.translate),
                label: const Text('Translate Selected Text'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: _selectedText.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TranslationPage(initialText: _selectedText),
                          ),
                        );
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}