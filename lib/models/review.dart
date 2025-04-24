import 'dart:developer';

class Review {
  final String? authorName;
  final double? rating;
  final String? text;
  final String? timeAgo;
  final String? profilePhotoUrl;
  final String? relativeTimeDescription;

  Review({
    this.authorName,
    this.rating,
    this.text,
    this.timeAgo,
    this.profilePhotoUrl,
    this.relativeTimeDescription,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Debug logging
    log('DEBUG REVIEW_PARSE: Processing review with keys: ${json.keys.join(', ')}');
    
    // Handle rating values
    double? ratingValue;
    if (json['rating'] != null) {
      if (json['rating'] is int) {
        ratingValue = (json['rating'] as int).toDouble();
      } else if (json['rating'] is double) {
        ratingValue = json['rating'];
      } else if (json['rating'] is String) {
        ratingValue = double.tryParse(json['rating']);
      }
    }
    
    log('DEBUG REVIEW_PARSE: Author name value: ${json['author_name'] ?? json['authorName'] ?? json['user_name'] ?? json['userName'] ?? 'null'}');
    log('DEBUG REVIEW_PARSE: Rating value: $ratingValue');
    log('DEBUG REVIEW_PARSE: Text value: ${json['text'] ?? json['review_text'] ?? json['reviewText'] ?? json['content'] ?? 'null'}');
    
    return Review(
      authorName: json['author_name'] ?? json['authorName'] ?? json['user_name'] ?? json['userName'],
      rating: ratingValue,
      text: json['text'] ?? json['review_text'] ?? json['reviewText'] ?? json['content'],
      timeAgo: json['time_ago'] ?? json['timeAgo'],
      profilePhotoUrl: json['profile_photo_url'] ?? json['profilePhotoUrl'] ?? json['avatar'],
      relativeTimeDescription: json['relative_time_description'] ?? json['relativeTimeDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author_name': authorName,
      'rating': rating,
      'text': text,
      'time_ago': timeAgo,
      'profile_photo_url': profilePhotoUrl,
      'relative_time_description': relativeTimeDescription,
    };
  }
}
