import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  // 위치 권한 확인 및 요청
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 위치 권한 요청
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // 현재 위치 가져오기
  Future<Position?> getCurrentLocation() async {
    final hasPermission = await checkLocationPermission();
    if (!hasPermission) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  // 두 지점 사이의 거리 계산
  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  // 거리를 문자열로 변환 (1km 이상이면 km, 아니면 m)
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters >= 1000) {
      final km = (distanceInMeters / 1000).toStringAsFixed(1);
      return '$km km';
    } else {
      final m = distanceInMeters.round();
      return '$m m';
    }
  }
}
