// lib/config/api_config.dart
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:5904';
  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static String? getToken() {
    return _token;
  }

  // API version prefix
  static const String apiPrefix = '/api/v1';
  
  // Helper method to get full API URL
  static String getApiUrl(String endpoint) {
    return '$baseUrl$apiPrefix$endpoint';
  }
  
  // Helper method for image URLs - updated to handle null values
  static String getImageUrl(String? path) {
    if (path == null) return '$baseUrl/assets/placeholder.png'; // Return placeholder path
    
    // If it's already a full URL, return it as is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    // If it's a relative path, append to base URL
    if (path.startsWith('/')) {
      return '$baseUrl$path';
    }
    
    // Otherwise, assume it's a relative path without leading slash
    return '$baseUrl/$path';
  }
}