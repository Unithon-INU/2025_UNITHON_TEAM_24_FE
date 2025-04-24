// lib/models/place.dart

import 'dart:developer';
import 'review.dart';
import '../config/api_config.dart';

class Place {
  final String id;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? ratingCount;
  final String? type;
  final List<String> tags;
  final String? imageUrl;
  final String? description;
  final List<Review> reviews;

  Place({
    required this.id,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.ratingCount,
    this.type,
    this.tags = const [],
    this.imageUrl,
    this.description,
    this.reviews = const [],
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    String? imageUrlValue;
    
    // For photo endpoint URL
    if (json['google_place_id'] != null) {
      imageUrlValue = '/api/v1/places/${json['google_place_id']}/photo';
    } else if (json['id'] != null) {
      imageUrlValue = '/api/v1/places/${json['id']}/photo';
    }
    
    // Process reviews with better logging
    List<Review> reviewsList = [];
    log('DEBUG PLACE: Processing JSON for place ${json['name'] ?? "unknown"}');
    log('DEBUG PLACE: JSON contains keys: ${json.keys.join(", ")}');
    
    if (json['reviews'] != null) {
      log('DEBUG REVIEWS: Found reviews in JSON for place ${json['name']}');
      log('DEBUG REVIEWS: Reviews type: ${json['reviews'].runtimeType}, count: ${json['reviews'] is List ? (json['reviews'] as List).length : 'not a list'}');
      
      if (json['reviews'] is List) {
        try {
          reviewsList = (json['reviews'] as List)
              .map((reviewJson) {
                if (reviewJson is Map<String, dynamic>) {
                  log('DEBUG REVIEWS: Processing review data with keys: ${reviewJson.keys.join(", ")}');
                  try {
                    return Review.fromJson(reviewJson);
                  } catch (e) {
                    log('DEBUG REVIEWS: Error parsing review: $e');
                    return null;
                  }
                }
                return null;
              })
              .where((review) => review != null)
              .cast<Review>()
              .toList();
          log('DEBUG REVIEWS: Successfully parsed ${reviewsList.length} reviews');
        } catch (e) {
          log('DEBUG REVIEWS: Error processing reviews list: $e');
        }
      }
    }
    
    // Determine ID
    String idValue = json['google_place_id'] ?? json['id'] ?? '';
    
    // Process tags
    List<String> tagsList = [];
    if (json['tags'] != null && json['tags'] is List) {
      tagsList = (json['tags'] as List)
          .map((tag) => tag.toString())
          .toList();
    }
    
    // Get rating count from multiple possible sources
    int? ratingCountValue;
    if (json['user_ratings_total'] is num) {
      ratingCountValue = (json['user_ratings_total'] as num).toInt();
    } else if (json['rating_count'] is num) {
      ratingCountValue = (json['rating_count'] as num).toInt();
    } else if (json['ratingCount'] is num) {
      ratingCountValue = (json['ratingCount'] as num).toInt();
    } else if (reviewsList.isNotEmpty) {
      // Use the actual number of reviews if available
      ratingCountValue = reviewsList.length;
    }
    
    return Place(
      id: idValue,
      name: json['name'] ?? '',
      address: json['address'],
      latitude: (json['latitude'] is num) ? (json['latitude'] as num).toDouble() : 0.0,
      longitude: (json['longitude'] is num) ? (json['longitude'] as num).toDouble() : 0.0,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : null,
      ratingCount: ratingCountValue,
      type: json['type'],
      tags: tagsList,
      imageUrl: imageUrlValue,
      description: json['description'],
      reviews: reviewsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'rating_count': ratingCount,
      'type': type,
      'tags': tags,
      'image_url': imageUrl,
      'description': description,
      'reviews': reviews.map((r) => r.toJson()).toList(),
    };
  }
}

// Helper function for string length
int min(int a, int b) => a < b ? a : b;