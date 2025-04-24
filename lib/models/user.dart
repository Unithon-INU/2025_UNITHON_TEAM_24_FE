// lib/models/user.dart
class User {
  final String id;
  final String email;
  final String? name;
  final String? profileImageUrl; // 필드명은 이전 수정과 동일하게 유지
  final DateTime? createdAt; // --- 수정: Nullable 타입으로 변경 ---

  User({
    required this.id,
    required this.email,
    this.name,
    this.profileImageUrl,
    this.createdAt, // --- 수정: required 제거 ---
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // createdAt 파싱 로직 강화 (null 및 타입 오류 처리)
    DateTime? parseCreatedAt() {
      final createdAtValue = json['created_at'];
      if (createdAtValue == null) return null;
      if (createdAtValue is String) return DateTime.tryParse(createdAtValue);
      // 백엔드에서 Timestamp (초 단위 정수)로 오는 경우
      if (createdAtValue is int) return DateTime.fromMillisecondsSinceEpoch(createdAtValue * 1000);
      // Timestamp (밀리초 단위 정수)로 오는 경우
      // if (createdAtValue is int) return DateTime.fromMillisecondsSinceEpoch(createdAtValue);
      return null; // 그 외의 경우는 null 처리
    }

    return User(
      id: json['id'] ?? json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['displayName'],
      profileImageUrl: json['photoUrl'] ?? json['profile_image_url'], // 필드명 유지
      createdAt: parseCreatedAt(), // 수정된 파싱 로직 사용
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl, // 필드명 유지
      // --- 수정: null 체크 후 변환 ---
      'created_at': createdAt?.toIso8601String(),
    };
  }
}