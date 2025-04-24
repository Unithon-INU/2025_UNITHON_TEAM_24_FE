// lib/services/api_service.dart

import 'dart:convert';
import 'dart:math';  // min 함수를 위한 import
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

import '../models/user.dart' as app_user;
import '../models/route.dart';
import '../models/place.dart';
import '../models/preference.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

/// HTTP + Firebase Auth 기반 주요 API 서비스
class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, String>> _getHeaders() async {
    final token = ApiConfig.getToken();
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      print('ApiService: Token length: ${token.length}');
      print('ApiService: Token prefix: ${token.substring(0, 20)}...');
    }

    print('ApiService: Token added to request');
    return headers;
  }

  /// 사용자 경로 목록 조회
  Future<List<TravelRoute>> getUserRoutes() async {
    final url = Uri.parse('$baseUrl/api/v1/routes');
    final headers = await _getHeaders();

    print('ApiService: Fetching user routes from $url');

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        print('ApiService: Fetched ${data.length} routes');
        return data.map((e) => TravelRoute.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        print('ApiService: Authentication failed (401). Response: ${response.body}');
        print('ApiService: Returning empty routes list after auth failure');
        return [];
      } else {
        print('ApiService: Failed to get user routes: ${response.statusCode}. Response: ${response.body}');
        throw Exception('경로 목록을 불러오는데 실패했습니다: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('ApiService: Exception in getUserRoutes: $e');
      return [];
    }
  }

  /// 경로 생성
  Future<TravelRoute> generateRoute(TravelPreference preference) async {
    final url = Uri.parse('$baseUrl/api/v1/routes/generate');
    final headers = await _getHeaders();

    print('ApiService: Generating route with preference: ${preference.toString()}');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(preference.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('ApiService: Route generated successfully');
      return TravelRoute.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }

    print('ApiService: Failed to generate route: ${response.statusCode}');
    throw Exception('경로 생성에 실패했습니다: ${response.reasonPhrase}');
  }

  /// 경로 생성 (예외 포장)
  Future<Map<String, dynamic>> safeGenerateRoute(TravelPreference preference) async {
    try {
      final route = await generateRoute(preference);
      return {'success': true, 'data': route};
    } catch (e) {
      print('ApiService: Error in safeGenerateRoute: $e');
      return {
        'success': false,
        'error': e.toString(),
        'friendlyMessage': '경로 생성에 실패했습니다. 다시 시도해주세요.'
      };
    }
  }

  /// 경로 삭제
  Future<void> deleteRoute(String routeId) async {
    final url = Uri.parse('$baseUrl/api/v1/routes/$routeId');
    final headers = await _getHeaders();

    print('ApiService: Deleting route $routeId');

    final response = await http.delete(url, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 204) {
      print('ApiService: Route deleted successfully');
      return;
    }

    print('ApiService: Failed to delete route: ${response.statusCode}');
    throw Exception('경로 삭제에 실패했습니다: ${response.reasonPhrase}');
  }

  /// 경로 업데이트
  Future<TravelRoute> updateRoute(TravelRoute route) async {
    final url = Uri.parse('$baseUrl/api/v1/routes/${route.id}');
    final headers = await _getHeaders();

    print('ApiService: Updating route ${route.id}');

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(route.toJson()),
    );

    if (response.statusCode == 200) {
      print('ApiService: Route updated successfully');
      return TravelRoute.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }

    print('ApiService: Failed to update route: ${response.statusCode}');
    throw Exception('경로 업데이트에 실패했습니다: ${response.reasonPhrase}');
  }

  /// 장소 상세 정보 조회
  Future<Place> getPlaceById(String id) async {
    final url = Uri.parse('$baseUrl/api/v1/places/$id');
    final headers = await _getHeaders();

    print('ApiService: Fetching place details for $id');

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      print('ApiService: Place details fetched successfully');
      return Place.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }

    print('ApiService: Failed to get place details: ${response.statusCode}');
    throw Exception('장소 정보를 불러오는데 실패했습니다: ${response.reasonPhrase}');
  }

  // Add a helper method to handle API errors
  void _handleApiError(http.Response response) {
    print('ApiService: Error response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 401) {
      print('ApiService: Authentication failed (401)');
      throw Exception('Authentication failed. Please log in again.');
    } else {
      throw Exception('API request failed: ${response.reasonPhrase}');
    }
  }

  // Update your getRouteById method to use the improved error handling
  Future<TravelRoute> getRouteById(String id) async {
    print("ApiService: Fetching route with ID: $id");

    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/v1/routes/$id');
      print("ApiService: Request URL: $uri");

      final response = await http.get(uri, headers: headers);
      print("ApiService: Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        print("ApiService: Response data: ${responseData.toString().substring(0, min(100, responseData.toString().length))}...");

        if (responseData is Map<String, dynamic>) {
          final route = TravelRoute.fromJson(responseData);
          print("ApiService: Route parsed successfully. Places: ${route.places.length}");
          return route;
        } else {
          print("ApiService: Invalid response format: $responseData");
          throw Exception('Invalid response format: expected Map<String, dynamic>');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Try public access as fallback
        return _tryPublicRouteAccess(id);
      } else {
        _handleApiError(response);
        throw Exception('Failed to load route: ${response.statusCode}');
      }
    } catch (e) {
      print("ApiService: Exception during API call: $e");
      throw Exception('API 요청 중 오류 발생: $e');
    }
  }

  // Extract the public route access to a separate method
  Future<TravelRoute> _tryPublicRouteAccess(String id) async {
    print("ApiService: Authentication failed. Trying public access...");

    final publicUri = Uri.parse('$baseUrl/api/v1/public/routes/$id');
    print("ApiService: Trying public URL: $publicUri");

    final publicResponse = await http.get(
      publicUri, 
      headers: {'Content-Type': 'application/json; charset=UTF-8'}
    );

    if (publicResponse.statusCode == 200) {
      final publicData = jsonDecode(utf8.decode(publicResponse.bodyBytes));
      final publicRoute = TravelRoute.fromJson(publicData);
      print("ApiService: Public route access successful. Places: ${publicRoute.places.length}");
      return publicRoute;
    }

    print("ApiService: Public access also failed: ${publicResponse.statusCode}");
    throw Exception('인증에 실패했습니다. 로그인이 필요합니다.');
  }
}

// Rest of your existing code for PlacesApiService...