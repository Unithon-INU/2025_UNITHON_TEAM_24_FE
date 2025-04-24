// lib/services/storage_service.dart
import 'dart:convert'; // JSON 인코딩/디코딩 위해 추가
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/preference.dart';
import '../models/user.dart'; // User 모델 import 추가

class StorageService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _preferenceKey = 'travel_preference';
  static const String _userKey = 'current_user'; // 사용자 정보 저장을 위한 키 추가

  // 토큰 저장
  Future<void> saveToken(String token) async {
    print("StorageService: Saving token...");
    await _secureStorage.write(key: _tokenKey, value: token);
    print("StorageService: Token saved.");
  }

  // 토큰 가져오기
  Future<String?> getToken() async {
    print("StorageService: Reading token...");
    final token = await _secureStorage.read(key: _tokenKey);
    print("StorageService: Token read ${token != null ? '(found)' : '(not found)'}.");
    return token;
  }

  // 토큰 삭제
  Future<void> deleteToken() async {
    print("StorageService: Deleting token...");
    await _secureStorage.delete(key: _tokenKey);
    print("StorageService: Token deleted.");
  }

  // --- 사용자 정보 저장 (추가) ---
  Future<void> saveUser(User user) async {
    print("StorageService: Saving user data for ${user.email}");
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = jsonEncode(user.toJson()); // User 객체를 JSON 문자열로 인코딩
      await prefs.setString(_userKey, userJsonString);
      print("StorageService: User data saved.");
    } catch (e) {
       print("StorageService Error: Failed to save user data: $e");
    }
  }

  // --- 사용자 정보 가져오기 (추가) ---
  Future<User?> getUser() async {
    print("StorageService: Reading user data...");
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(_userKey);
      if (userJsonString != null) {
        final userJson = jsonDecode(userJsonString) as Map<String, dynamic>; // JSON 문자열 디코딩
        final user = User.fromJson(userJson); // JSON을 User 객체로 변환
        print("StorageService: User data read successfully for ${user.email}.");
        return user;
      }
      print("StorageService: No user data found.");
      return null;
    } catch (e) {
      print("StorageService Error: Failed to read user data: $e");
      // 오류 발생 시 기존 데이터 삭제 고려
      await deleteUser();
      return null;
    }
  }

  // --- 사용자 정보 삭제 (추가) ---
  Future<void> deleteUser() async {
    print("StorageService: Deleting user data...");
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      print("StorageService: User data deleted.");
    } catch (e) {
      print("StorageService Error: Failed to delete user data: $e");
    }
  }


  // 여행 선호도 저장
  // Add this method to your StorageService class
  // Remove this duplicate method
  // Future<void> savePreference(Map<String, dynamic> preference) async {
  //   try {
  //     // Implement according to your storage mechanism
  //     // For example, using shared preferences:
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('travel_preference', jsonEncode(preference));
  //     print('StorageService: Travel preference saved.');
  //   } catch (e) {
  //     print('StorageService Error: Failed to save preference: $e');
  //     throw Exception('Failed to save travel preference: $e');
  //   }
  // }
  
  // Keep this method
  Future<void> savePreference(TravelPreference preference) async {
    print("StorageService: Saving travel preference...");
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefJson = preference.toJson();
      // Map<String, dynamic>을 직접 저장할 수 없으므로 JSON 문자열로 변환
      await prefs.setString(_preferenceKey, jsonEncode(prefJson));
      print("StorageService: Travel preference saved.");
    } catch (e) {
      print("StorageService Error: Failed to save preference: $e");
    }
  }

  // 여행 선호도 가져오기
  Future<TravelPreference?> getPreference() async {
    print("StorageService: Reading travel preference...");
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefString = prefs.getString(_preferenceKey);
      if (prefString != null) {
        // JSON 문자열을 Map<String, dynamic>으로 디코딩
        final prefJson = jsonDecode(prefString) as Map<String, dynamic>;
        final preference = TravelPreference.fromJson(prefJson);
         print("StorageService: Travel preference read successfully.");
        return preference;
      }
       print("StorageService: No travel preference found.");
      return null;
    } catch (e) {
       print("StorageService Error: Failed to read preference: $e");
       await deletePreference(); // 오류 시 삭제
       return null;
    }
  }

  // 여행 선호도 삭제
  Future<void> deletePreference() async {
     print("StorageService: Deleting travel preference...");
     try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_preferenceKey);
       print("StorageService: Travel preference deleted.");
     } catch (e) {
        print("StorageService Error: Failed to delete preference: $e");
     }
  }
}