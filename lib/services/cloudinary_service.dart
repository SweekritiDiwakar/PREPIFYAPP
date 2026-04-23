import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  CloudinaryService._();

  static const String _cloudName = 'dz0hjrw4q';
  static const String _uploadPreset = 'prepify_upload';
  // ────────────────────────────────────────────────────────────────

  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Uploads [imageFile] to Cloudinary and returns the secure URL.
  static Future<String> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['upload_preset'] = _uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        debugPrint('Cloudinary upload failed: $body');
        
        // Try to parse the exact error message from Cloudinary
        try {
          final errorJson = jsonDecode(body) as Map<String, dynamic>;
          final errorMessage = errorJson['error']?['message'] as String?;
          if (errorMessage != null && errorMessage.isNotEmpty) {
            throw StateError('Cloudinary Error: $errorMessage. Please check your upload preset in the Cloudinary Dashboard.');
          }
        } catch (_) {
          // If JSON parsing fails, fallback to generic error
        }
        
        throw StateError('Image upload failed (${response.statusCode}). Please try again.');
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      final url = json['secure_url'] as String?;

      if (url == null || url.isEmpty) {
        throw StateError('Image upload failed. No URL returned.');
      }

      return url;
    } on SocketException {
      throw StateError('No internet connection. Please check your network and try again.');
    } catch (e) {
      if (e is StateError) rethrow;
      debugPrint('CloudinaryService.uploadImage error: $e');
      throw StateError('Image upload failed. Please try again.');
    }
  }
}