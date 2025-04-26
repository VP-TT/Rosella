import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart'; // Import your ApiService

class UltrasoundUploadScreen extends StatefulWidget {
  @override
  _UltrasoundUploadScreenState createState() => _UltrasoundUploadScreenState();
}

class _UltrasoundUploadScreenState extends State<UltrasoundUploadScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _predictionResult = "";

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Upload the image to the API and get the result
  Future<void> _predictImage() async {
    if (_image != null) {
      String result = await ApiService.uploadUltrasoundImage(_image!);
      setState(() {
        _predictionResult = result;
      });
    } else {
      setState(() {
        _predictionResult = "No image selected.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Ultrasound Image'),
      backgroundColor: const Color(0xFFE75A7C),),
      body: Center(
        child: SingleChildScrollView( // allows content to be scrollable if needed
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _image!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _predictImage,
                  child: const Text('Predict PCOS'),
                ),
                const SizedBox(height: 24),
                if (_predictionResult.isNotEmpty)
                  Text(
                    _predictionResult,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
