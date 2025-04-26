import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// ignore: unused_import
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String _baseUrl =
      'http://10.0.2.2:5000'; // Your Flask server's base URL

  // Predict PCOS based on symptoms
  static Future<String> predictPCOS(Map<String, dynamic> userInput) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/predict',
      ); // Adjust to your Flask endpoint
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userInput),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['prediction']; // Adjust to your response format
      } else {
        throw Exception('Failed to get prediction');
      }
    } catch (e) {
      print('API ERROR: $e');
      return 'Error: Could not connect to prediction service';
    }
  }

  // Upload ultrasound image for prediction
  static Future<String> uploadUltrasoundImage(File image) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/predict-image',
      ); // Your ultrasound model endpoint

      // Create a multipart request to send the image
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        return data['prediction']; // Response from ultrasound model prediction
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print('API ERROR: $e');
      return 'Error: Could not connect to ultrasound prediction service';
    }
  }
}
