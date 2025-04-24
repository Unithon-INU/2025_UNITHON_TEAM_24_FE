import 'package:flutter/foundation.dart';
import '../models/preference.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class PreferenceProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;
  TravelPreference? _preference;
  bool _isLoading = false;
  String? _error;

  PreferenceProvider({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService {
    _loadSavedPreference();
  }

  TravelPreference? get preference => _preference;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 저장된 선호도 불러오기
  Future<void> _loadSavedPreference() async {
    _isLoading = true;
    notifyListeners();

    try {
      _preference = await _storageService.getPreference();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 선호도 저장
  Future<void> savePreference({
    required String region,
    required String style,
    required String budget,
    required String companion,
    String? specialRequest,
    required String mobilityLimit,
    required bool usePublicTransport,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final preference = TravelPreference(
        region: region,
        style: style,
        budget: budget,
        companion: companion,
        specialRequest: specialRequest,
        mobilityLimit: mobilityLimit,
        usePublicTransport: usePublicTransport,
      );

      // 로컬 스토리지에 저장
      // Change this line
      await _storageService.savePreference(preference);
      
      // To use the toJson method if needed
      await _storageService.savePreference(preference);
      
      _preference = preference;
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 선호도 초기화
  Future<void> clearPreference() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.deletePreference();
      _preference = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 오류 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
