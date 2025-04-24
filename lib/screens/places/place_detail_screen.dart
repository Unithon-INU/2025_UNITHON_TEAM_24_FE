// lib/screens/places/place_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:developer' as developer;

import '../../models/place.dart';
import '../../models/review.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class PlaceDetailScreen extends StatelessWidget {
  final String? placeId;
  
  const PlaceDetailScreen({Key? key, this.placeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final id = placeId ?? ModalRoute.of(context)?.settings.arguments as String?;
    
    developer.log('PlaceDetailScreen: Building with placeId: $id');
    
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text('장소 상세')),
        body: Center(child: Text('장소 ID가 유효하지 않습니다')),
      );
    }

    return FutureBuilder<Place>(
      future: ApiService(baseUrl: ApiConfig.baseUrl).getPlaceById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('로딩 중...')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          developer.log('PlaceDetailScreen Error: ${snapshot.error}');
          return Scaffold(
            appBar: AppBar(title: Text('오류')),
            body: Center(child: Text('장소 정보를 불러올 수 없습니다: ${snapshot.error}')),
          );
        }

        final place = snapshot.data!;
        developer.log('PlaceDetailScreen: Loaded place ${place.name} with ${place.reviews.length} reviews');
        
        // Log reviews data for debugging
        if (place.reviews.isEmpty) {
          developer.log('PlaceDetailScreen: No reviews found for this place');
        } else {
          developer.log('PlaceDetailScreen: First review: ${place.reviews.first.text?.substring(0, place.reviews.first.text!.length > 50 ? 50 : place.reviews.first.text!.length) ?? "No text"}');
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(place.name),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Refresh button for testing
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  // Force reload
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceDetailScreen(placeId: id),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                if (place.imageUrl != null)
                  Container(
                    width: double.infinity,
                    height: 220,
                    child: Image.network(
                      ApiConfig.baseUrl + place.imageUrl!,
                      fit: BoxFit.cover,
                      headers: {
                        'Authorization': 'Bearer ${ApiConfig.getToken()}',
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        developer.log('Error loading image: $error');
                        return Container(
                          width: double.infinity,
                          height: 220,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  ),

                // Info section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 8),
                      if (place.address != null) ...[
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                place.address!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],

                      // Rating section
                      if (place.rating != null) ...[
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              place.rating!.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (place.ratingCount != null) ...[
                              SizedBox(width: 4),
                              Text(
                                '(${place.ratingCount} reviews)',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 24),
                      ],

                      // Reviews section
                      Text(
                        '리뷰 (${place.reviews.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      
                      if (place.reviews.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
                                SizedBox(height: 16),
                                Text(
                                  '아직 리뷰가 없습니다',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: place.reviews.length,
                          itemBuilder: (context, index) {
                            final review = place.reviews[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.grey[300],
                                          child: Icon(
                                            Icons.person,
                                            size: 20,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                review.authorName ?? 'Anonymous',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (review.rating != null)
                                                Row(
                                                  children: [
                                                    Icon(Icons.star,
                                                        size: 16,
                                                        color: Colors.amber),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      review.rating!.toString(),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (review.timeAgo != null)
                                          Text(
                                            review.timeAgo!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (review.text != null && review.text!.isNotEmpty) ...[
                                      SizedBox(height: 12),
                                      Text(
                                        review.text!,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        
                      SizedBox(height: 24),
                      
                      // Add Review Button (for future implementation)
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('리뷰 작성 기능은 개발 중입니다'))
                          );
                        },
                        icon: Icon(Icons.rate_review),
                        label: Text('리뷰 작성'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}