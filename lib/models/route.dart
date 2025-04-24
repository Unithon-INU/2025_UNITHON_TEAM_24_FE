// lib/models/route.dart
// *** 수정: 올바른 google_maps_flutter import ***
import 'package:google_maps_flutter/google_maps_flutter.dart'; // LatLng 사용 시 필요할 수 있음
import 'place.dart';

// --- MovingInfo 클래스 ---
class MovingInfo {
  final String distance;
  final String duration;
  final String transportType;
  final List<Map<String, dynamic>>? steps;
  final String? overviewPolyline;

  MovingInfo({
    required this.distance,
    required this.duration,
    required this.transportType,
    this.steps,
    this.overviewPolyline,
  });

  factory MovingInfo.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>>? parsedSteps;
    if (json['steps'] != null && json['steps'] is List) {
       try {
          parsedSteps = (json['steps'] as List)
              .whereType<Map<String, dynamic>>() // .where + .map 보다 간결
              .toList();
       } catch (e) {
          print("Error parsing steps for MovingInfo: $e");
          parsedSteps = null;
       }
    }
    String? polylineString = json['overview_polyline']?.toString();

    return MovingInfo(
      distance: json['distance']?.toString() ?? '정보 없음',
      duration: json['duration']?.toString() ?? '정보 없음',
      transportType: json['transport_type']?.toString() ?? 'unknown',
      steps: parsedSteps,
      overviewPolyline: polylineString,
    );
  }

  // *** 추가: toJson 메소드 ***
  // API 요청 시 필요한 필드만 포함하도록 수정 가능
  Map<String, dynamic> toJson() => {
    'distance': distance,
    'duration': duration,
    'transport_type': transportType,
    'steps': steps, // steps 내용도 Map 형태여야 함
    'overview_polyline': overviewPolyline,
  };
}

// --- TravelRoute 클래스 ---
class TravelRoute {
  final String id;
  final List<Place> places;
  final List<MovingInfo> movingInfo;
  final String estimatedDuration;
  final String totalDistance;
  final DateTime createdAt;
  final String ownerId;

  TravelRoute({
    required this.id,
    required this.places,
    required this.movingInfo,
    required this.estimatedDuration,
    required this.totalDistance,
    required this.createdAt,
    required this.ownerId,
  });

  factory TravelRoute.fromJson(Map<String, dynamic> json) {
    var movingInfoList = <MovingInfo>[];
    if (json['moving_info'] != null && json['moving_info'] is List) {
       try {
          movingInfoList = (json['moving_info'] as List)
              .whereType<Map<String, dynamic>>() // 타입 체크 및 필터링
              .map((info) => MovingInfo.fromJson(info))
              .toList();
       } catch (e) {
         print("Error parsing moving_info in TravelRoute.fromJson: $e");
         movingInfoList = [];
       }
    }

    List<Place> placesList = [];
     if (json['places'] != null && json['places'] is List) {
       try {
          placesList = (json['places'] as List)
              .whereType<Map<String, dynamic>>() // 타입 체크 및 필터링
              .map((place) => Place.fromJson(place))
              .toList();
       } catch (e) {
           print("Error parsing places in TravelRoute.fromJson: $e");
           placesList = [];
       }
     }

    return TravelRoute(
      id: json['id']?.toString() ?? '',
      places: placesList,
      movingInfo: movingInfoList,
      estimatedDuration: json['estimated_duration']?.toString() ?? '정보 없음',
      totalDistance: json['total_distance']?.toString() ?? '정보 없음',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      ownerId: json['owner_id']?.toString() ?? '',
    );
  }

  // *** 수정/추가: toJson 메소드 ***
  // ApiService의 updateRoute에서 사용됨. Place 모델에도 toJson 구현 필요.
  Map<String, dynamic> toJson() => {
        // 'id': id, // 보통 PUT 요청 시 id는 URL 경로에 포함됨
        'places': places.map((place) => place.toJson()).toList(),
        // movingInfo 는 보통 서버에서 재계산하므로 보낼 필요 없을 수 있음
        // 'moving_info': movingInfo.map((info) => info.toJson()).toList(),
        // 다른 필드들도 서버에서 필요로 하는 형식에 맞춰 추가/제거
        // 'estimated_duration': estimatedDuration,
        // 'total_distance': totalDistance,
      };
}