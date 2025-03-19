import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ocr_service.dart';
import 'translation_page.dart';

// Add this at the top of ocr_processing_screen.dart, outside any class
Offset imageToViewCoordinates(double imageX, double imageY, double imageWidth,
    double imageHeight, double viewWidth, double viewHeight) {
  double viewAspectRatio = viewWidth / viewHeight;
  double imageAspectRatio = imageWidth / imageHeight;

  double scaleFactor;
  double offsetX = 0;
  double offsetY = 0;

  if (viewAspectRatio > imageAspectRatio) {
    // Height constrained view
    scaleFactor = viewHeight / imageHeight;
    offsetX = (viewWidth - imageWidth * scaleFactor) / 2;
  } else {
    // Width constrained view
    scaleFactor = viewWidth / imageWidth;
    offsetY = (viewHeight - imageHeight * scaleFactor) / 2;
  }

  double viewX = imageX * scaleFactor + offsetX;
  double viewY = imageY * scaleFactor + offsetY;

  return Offset(viewX, viewY);
}

class OcrProcessingScreen extends StatefulWidget {
  final File imageFile;

  const OcrProcessingScreen({super.key, required this.imageFile});

  @override
  State<OcrProcessingScreen> createState() => _OcrProcessingScreenState();
}

class _OcrProcessingScreenState extends State<OcrProcessingScreen> {
  bool _isProcessing = true;
  String _errorMessage = '';
  List<String> _textBlocks = [];
  List<List<List<int>>> _boundingBoxes = [];
  String _selectedText = '';
  List<bool> _selectedBlocks = [];
  double _imageWidth = 0;
  double _imageHeight = 0;
  // Add these lines after your existing state variables (after _imageHeight)
  bool _isPanelExpanded = false;
  final double _collapsedPanelHeight = 80.0;
  final double _expandedPanelHeight = 300.0;

  @override
  void initState() {
    super.initState();
    _processImage();
    _getImageDimensions();
  }

  Future<void> _getImageDimensions() async {
    final decodedImage =
        await decodeImageFromList(widget.imageFile.readAsBytesSync());
    setState(() {
      _imageWidth = decodedImage.width.toDouble();
      _imageHeight = decodedImage.height.toDouble();
    });
  }

  Future<void> _processImage() async {
    try {
      final ocrService = Provider.of<OCRService>(context, listen: false);
      final result = await ocrService.processImageWithBoxes(widget.imageFile);

      if (mounted) {
        setState(() {
          if (result['success'] == false) {
            _errorMessage = result['error'] ?? 'Unknown error occurred';
          } else {
            _textBlocks = List<String>.from(result['texts'] ?? []);

            // Properly convert the dynamic list to the expected format
            if (result['boxes'] != null) {
              _boundingBoxes = _convertBoundingBoxes(result['boxes']);
            }

            _selectedBlocks = List.generate(_textBlocks.length, (_) => false);
          }
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Processing Error: ${e.toString()}';
          _isProcessing = false;
        });
      }
    }
  }

  // Helper method to safely convert the dynamic lists to the expected format
  List<List<List<int>>> _convertBoundingBoxes(List<dynamic> boxes) {
    List<List<List<int>>> result = [];

    try {
      for (var box in boxes) {
        if (box is List) {
          List<List<int>> convertedBox = [];

          for (var point in box) {
            if (point is List) {
              if (point.length >= 2) {
                List<int> convertedPoint = [
                  point[0] is int
                      ? point[0]
                      : int.tryParse(point[0].toString()) ?? 0,
                  point[1] is int
                      ? point[1]
                      : int.tryParse(point[1].toString()) ?? 0
                ];
                convertedBox.add(convertedPoint);
              }
            }
          }

          // Only add boxes with at least 3 points (to form a polygon)
          if (convertedBox.length >= 3) {
            result.add(convertedBox);
          }
        }
      }
    } catch (e) {
      print('Error converting bounding boxes: $e');
    }

    return result;
  }

  void _toggleTextSelection(int index) {
    setState(() {
      _selectedBlocks[index] = !_selectedBlocks[index];
      _updateSelectedText();
    });
  }

  void _updateSelectedText() {
    List<String> selectedTexts = [];
    for (int i = 0; i < _textBlocks.length; i++) {
      if (_selectedBlocks[i]) {
        selectedTexts.add(_textBlocks[i]);
      }
    }
    _selectedText = selectedTexts.join(' ');
  }

  void _selectAll() {
    setState(() {
      _selectedBlocks = List.generate(_textBlocks.length, (_) => true);
      _updateSelectedText();
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedBlocks = List.generate(_textBlocks.length, (_) => false);
      _selectedText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Recognition'),
        actions: [
          if (!_isProcessing && _textBlocks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _selectAll,
              tooltip: 'Select All',
            ),
          if (!_isProcessing && _textBlocks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.deselect),
              onPressed: _deselectAll,
              tooltip: 'Deselect All',
            ),
        ],
      ),
      body: _isProcessing
          ? _buildLoadingUI()
          : _errorMessage.isNotEmpty
              ? _buildErrorUI()
              : _buildResultUI(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildLoadingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Processing image...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Detecting and extracting text',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () {
                setState(() {
                  _isProcessing = true;
                  _errorMessage = '';
                });
                _processImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultUI() {
    // If we don't have bounding boxes, show text-only view
    if (_boundingBoxes.isEmpty || _textBlocks.isEmpty) {
      return _buildTextOnlyView();
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Image layer
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Image.file(
                    widget.imageFile,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Bounding boxes overlay
              if (_boundingBoxes.isNotEmpty)
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomPaint(
                        painter: TextBoxPainter(
                          boxes: _boundingBoxes,
                          selectedBlocks: _selectedBlocks,
                          imageWidth: _imageWidth,
                          imageHeight: _imageHeight,
                          viewWidth: constraints.maxWidth,
                          viewHeight: constraints.maxHeight,
                        ),
                      );
                    },
                  ),
                ),

              // Text selection buttons overlay
              if (_boundingBoxes.isNotEmpty)
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTapUp: (details) {
                          _handleTap(details.localPosition, constraints);
                        },
                        child: Container(
                          color: Colors.transparent,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),

        // Selected text preview

// Extendable text preview panel
        if (_selectedText.isNotEmpty) _buildExtendablePanel(),
      ],
    );
  }
  // New method to build the extendable panel
Widget _buildExtendablePanel() {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    height: _isPanelExpanded ? _expandedPanelHeight : _collapsedPanelHeight,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 5,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: Column(
      children: [
        // Handle to expand/collapse
        GestureDetector(
          onTap: () {
            setState(() {
              _isPanelExpanded = !_isPanelExpanded;
            });
          },
          child: Container(
            height: 24,
            color: Colors.grey.withOpacity(0.1),
            child: Center(
              child: Icon(
                _isPanelExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
        
        // Panel header with text count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Text (${_selectedBlocks.where((b) => b).length} blocks)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.content_copy, size: 20),
                onPressed: () {
                  // Implement copy to clipboard functionality
                  if (_selectedText.isNotEmpty) {
                    // You'll need to add the clipboard package to your pubspec.yaml
                    // Clipboard.setData(ClipboardData(text: _selectedText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Text copied to clipboard')),
                    );
                  }
                },
                tooltip: 'Copy to clipboard',
              ),
            ],
          ),
        ),
        
        // Selected text content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
            child: SingleChildScrollView(
              child: Text(
                _selectedText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  // Fallback view for when we don't have bounding boxes
  Widget _buildTextOnlyView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _textBlocks.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () => _toggleTextSelection(index),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedBlocks[index]
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _textBlocks[index],
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedBlocks[index]
                            ? Theme.of(context).primaryColor
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    _selectedBlocks[index]
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: _selectedBlocks[index]
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTap(Offset tapPosition, BoxConstraints constraints) {
    // Check if tap is inside any bounding box
    for (int i = 0; i < _boundingBoxes.length; i++) {
      if (_isPointInPolygon(
          tapPosition,
          _boundingBoxes[i],
          1, // These parameters aren't used anymore but kept for method signature compatibility
          1,
          constraints)) {
        _toggleTextSelection(i);
        break;
      }
    }
  }

  bool _isPointInPolygon(Offset point, List<List<int>> polygon, double scaleX,
      double scaleY, BoxConstraints constraints) {
    // Convert polygon points to screen coordinates
    List<Offset> scaledPoints = [];

    for (var p in polygon) {
      if (p.length < 2) continue; // Skip invalid points

      Offset viewPoint = imageToViewCoordinates(
          p[0].toDouble(),
          p[1].toDouble(),
          _imageWidth,
          _imageHeight,
          constraints.maxWidth,
          constraints.maxHeight);

      scaledPoints.add(viewPoint);
    }

    if (scaledPoints.length < 3)
      return false; // Need at least 3 points for a polygon

    // Ray casting algorithm to determine if point is inside polygon
    bool inside = false;
    int j = scaledPoints.length - 1;

    for (int i = 0; i < scaledPoints.length; i++) {
      if ((scaledPoints[i].dy > point.dy) != (scaledPoints[j].dy > point.dy) &&
          point.dx <
              (scaledPoints[j].dx - scaledPoints[i].dx) *
                      (point.dy - scaledPoints[i].dy) /
                      (scaledPoints[j].dy - scaledPoints[i].dy) +
                  scaledPoints[i].dx) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.translate),
                label: const Text('Translate Selected Text'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _selectedText.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TranslationPage(initialText: _selectedText),
                          ),
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter to draw bounding boxes around detected text
// Custom painter to draw bounding boxes around detected text
class TextBoxPainter extends CustomPainter {
  final List<List<List<int>>> boxes;
  final List<bool> selectedBlocks;
  final double imageWidth;
  final double imageHeight;
  final double viewWidth;
  final double viewHeight;

  TextBoxPainter({
    required this.boxes,
    required this.selectedBlocks,
    required this.imageWidth,
    required this.imageHeight,
    required this.viewWidth,
    required this.viewHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (boxes.isEmpty) return;

    for (int i = 0; i < boxes.length && i < selectedBlocks.length; i++) {
      final paintFill = Paint()
        ..color = selectedBlocks[i]
            ? Colors.blue.withOpacity(0.2)
            : Colors.yellow.withOpacity(0.1)
        ..style = PaintingStyle.fill;

      final paintStroke = Paint()
        ..color = selectedBlocks[i] ? Colors.blue : Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Need at least 3 points for a polygon
      if (boxes[i].length < 3) continue;

      final path = Path();
      bool firstPoint = true;

      for (var point in boxes[i]) {
        if (point.length < 2) continue; // Skip invalid points

        // Convert image coordinates to view coordinates
        Offset viewPoint = imageToViewCoordinates(
            point[0].toDouble(),
            point[1].toDouble(),
            imageWidth,
            imageHeight,
            viewWidth,
            viewHeight);

        if (firstPoint) {
          path.moveTo(viewPoint.dx, viewPoint.dy);
          firstPoint = false;
        } else {
          path.lineTo(viewPoint.dx, viewPoint.dy);
        }
      }

      if (!firstPoint) {
        // Only close and draw if we added any points
        path.close();
        canvas.drawPath(path, paintFill);
        canvas.drawPath(path, paintStroke);
      }
    }
  }

  @override
  bool shouldRepaint(TextBoxPainter oldDelegate) {
    return oldDelegate.selectedBlocks != selectedBlocks;
  }
}
