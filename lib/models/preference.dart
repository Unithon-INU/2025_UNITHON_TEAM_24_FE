class TravelPreference {
  final String region;
  final String style;
  final String budget;
  final String companion;
  final String? specialRequest;
  final String mobilityLimit;
  final bool usePublicTransport;

  TravelPreference({
    required this.region,
    required this.style,
    required this.budget,
    required this.companion,
    this.specialRequest,
    required this.mobilityLimit,
    required this.usePublicTransport,
  });

  factory TravelPreference.fromJson(Map<String, dynamic> json) {
    return TravelPreference(
      region: json['region'],
      style: json['style'],
      budget: json['budget'],
      companion: json['companion'],
      specialRequest: json['specialRequest'],
      mobilityLimit: json['mobilityLimit'],
      usePublicTransport: json['usePublicTransport'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'style': style,
      'budget': budget,
      'companion': companion,
      'specialRequest': specialRequest,
      'mobilityLimit': mobilityLimit,
      'usePublicTransport': usePublicTransport,
      "latitude": 37.5665,
      "longitude": 126.978
    };
  }
}
