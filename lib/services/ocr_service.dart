import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class OCRService {
  static const String _apiUrl = "http://192.168.243.143:5000/ocr"; // Android emulator
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage(bool isCamera) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }

  // Original method preserved for backward compatibility
  Future<String> processImage(File image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path)
      );

      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      final Map<String, dynamic> data = json.decode(respStr);

      if (data['success'] == true) {
        return data['text'] ?? "No text detected";
      }
      return "OCR Error: ${data['error']}";
    } catch (e) {
      return "Connection Error: ${e.toString()}";
    }
  }

  // New method that returns detailed OCR results including bounding boxes
  Future<Map<String, dynamic>> processImageWithBoxes(File image) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
    request.files.add(
      await http.MultipartFile.fromPath('image', image.path)
    );

    print("Sending request to OCR server...");
    var streamedResponse = await request.send();
    final respStr = await streamedResponse.stream.bytesToString();
    
    print("Received response from OCR server");
    
    final Map<String, dynamic> data = json.decode(respStr);
    
    print("Success: ${data['success']}");
    if (data['boxes'] != null) {
      print("Number of boxes: ${data['boxes'].length}");
    }
    
    if (data['success'] == true) {
      // Handle text array from server
      List<String> texts = [];
      if (data['text'] != null) {
        if (data['text'] is String) {
          texts = data['text'].toString().split('\n');
        } else if (data['text'] is List) {
          texts = List<String>.from(data['text'].map((item) => item.toString()));
        }
      }
      
      return {
        'success': true,
        'texts': texts,
        'boxes': data['boxes'] ?? [],
        'totalDetections': data['totalDetections'] ?? texts.length
      };
    }
    
    return {
      'success': false,
      'error': data['error'] ?? "Unknown error"
    };
  } catch (e) {
    print("Error processing image with boxes: $e");
    return {
      'success': false,
      'error': "Connection Error: ${e.toString()}"
    };
  }
}
}