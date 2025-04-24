// lib/providers/route_provider.dart

import 'package:flutter/foundation.dart';
import '../models/route.dart';
import '../models/place.dart';
import '../models/preference.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// 경로 생성 상태 정의
enum RouteGenerationStatus { initial, loading, success, error }

/// 현재 여행 경로 및 리스트 관리를 담당하는 Provider
class RouteProvider with ChangeNotifier {
  RouteGenerationStatus _status = RouteGenerationStatus.initial;
  String? _errorMessage;
  TravelRoute? _currentRoute;
  List<TravelRoute> _routes = [];

  final ApiService _apiService;
  final StorageService _storageService;
  late TravelPreference _travelPreference;

  RouteProvider({
    required ApiService apiService,
    required StorageService storageService,
    required TravelPreference travelPreference,
  })  : _apiService = apiService,
        _storageService = storageService,
        _travelPreference = travelPreference;

  // Getters
  RouteGenerationStatus get status => _status;
  String? get error => _errorMessage;
  TravelRoute? get currentRoute => _currentRoute;
  List<TravelRoute> get routes => _routes;
  bool get isLoading => _status == RouteGenerationStatus.loading;

  // Remove the existing _setLoading method and add this one
  void _setLoading(bool isLoading) {
    if (isLoading) {
      _status = RouteGenerationStatus.loading;
    } else {
      // If we were in loading state, go back to initial
      // Otherwise keep the current state (success or error)
      if (_status == RouteGenerationStatus.loading) {
        _status = RouteGenerationStatus.initial;
      }
    }
    notifyListeners();
  }

  /// 현재 경로에 새로운 장소 추가
  void addPlaceToRoute(Place place) {
    if (_currentRoute == null) {
      _currentRoute = TravelRoute(
        id: 'new',
        places: [],
        movingInfo: [],
        estimatedDuration: '0',
        totalDistance: '0',
        createdAt: DateTime.now(),
        ownerId: '',
      );
    }
    _currentRoute!.places.add(place);
    notifyListeners();
  }

  /// 에러 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(RouteGenerationStatus newState) {
    _status = newState;
    notifyListeners();
  }

  /// 서버에 preference 저장 후 경로 생성 요청
  Future<void> generateRoute() async {
    _setState(RouteGenerationStatus.loading);
    try {
      await _storageService.savePreference(_travelPreference);
      final response = await _apiService.safeGenerateRoute(_travelPreference);
      if (response['success'] == true && response['data'] is TravelRoute) {
        _currentRoute = response['data'] as TravelRoute;
        _setState(RouteGenerationStatus.success);
      } else {
        _errorMessage = response['friendlyMessage'] as String?;
        _setState(RouteGenerationStatus.error);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setState(RouteGenerationStatus.error);
    }
  }

  /// 사용자 경로 목록 조회
  Future<void> fetchRoutes() async {
    _setState(RouteGenerationStatus.loading);
    try {
      _routes = await _apiService.getUserRoutes();
      _setState(RouteGenerationStatus.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(RouteGenerationStatus.error);
    }
  }

  /// 특정 경로를 currentRoute로 설정
  void setCurrentRoute(TravelRoute route) {
    _currentRoute = route;
    notifyListeners();
  }

  /// 경로 삭제
  Future<void> deleteRoute(String routeId) async {
    try {
      await _apiService.deleteRoute(routeId);
      _routes.removeWhere((r) => r.id == routeId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete route: $e');
    }
  }

  /// 경로 업데이트
  Future<void> updateRoute(TravelRoute route) async {
    _setState(RouteGenerationStatus.loading);
    try {
      final updated = await _apiService.updateRoute(route);
      _currentRoute = updated;
      _setState(RouteGenerationStatus.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(RouteGenerationStatus.error);
    }
  }

  /// ID로 특정 경로 조회
  Future<void> fetchRouteById(String id) async {
    _setState(RouteGenerationStatus.loading); // Use _setState instead of _setLoading
    try {
      print("RouteProvider: Fetching route with ID: $id");
      final route = await _apiService.getRouteById(id);
      print("RouteProvider: Route fetched successfully. Places count: ${route.places.length}");
      print("RouteProvider: Moving info count: ${route.movingInfo.length}");
      
      // 각 장소 정보 로깅
      for (var i = 0; i < route.places.length; i++) {
        final place = route.places[i];
        print("RouteProvider: Place $i - ID: ${place.id}, Name: ${place.name}");
      }
      
      _currentRoute = route;
      _setState(RouteGenerationStatus.success); // Use _setState instead of notifyListeners
    } catch (e) {
      print("RouteProvider: Error fetching route: $e");
      _errorMessage = e.toString();
      _setState(RouteGenerationStatus.error); // Set error state
      throw e;
    }
  }

  /// 리스트 순서 재배치
  void reorderPlaces(int oldIndex, int newIndex) {
    if (_currentRoute == null) return;
    final places = _currentRoute!.places;
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = places.removeAt(oldIndex);
    places.insert(newIndex, moved);
    notifyListeners();
  }

  /// 장소 제거
  Future<void> removePlaceFromRoute(String placeId) async {
    _currentRoute?.places.removeWhere((p) => p.id == placeId);
    notifyListeners();
    // TODO: 서버에도 반영하려면 API 호출 추가
  }

  /// preference 변경 후 경로 다시 생성
  Future<void> generateRouteWithPreference(TravelPreference preference) async {
    _travelPreference = preference;
    await generateRoute();
  }
}
