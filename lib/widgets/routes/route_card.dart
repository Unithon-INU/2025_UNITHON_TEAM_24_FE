// lib/widgets/routes/route_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:developer' as developer;
import '../../models/route.dart'; // TravelRoute 모델 경로 확인
import '../../providers/route_provider.dart';
import '../../config/api_config.dart'; // Add this import

class RouteCard extends StatelessWidget {
  final TravelRoute route;
  final VoidCallback? onTap; // 카드 전체 탭 이벤트

  const RouteCard({
    Key? key,
    required this.route,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);

    // 경로 이름, 출발지, 도착지 설정 (장소 목록이 비어있을 경우 대비)
    final routeName = route.places.isNotEmpty
        ? '${route.places.first.name}에서 ${route.places.last.name}까지의 여정'
        : '새로운 여정';

    final startPlaceName = route.places.isNotEmpty ? route.places.first.name : '출발지 없음';
    final endPlaceName = route.places.length > 1 ? route.places.last.name : '도착지 없음';
    final createdDate = _formatDate(route.createdAt);

    // Debug logging for image issues
    if (route.places.isNotEmpty) {
      developer.log('[DEBUG] First place: ${route.places.first.name}', name: 'RouteCard');
      developer.log('[DEBUG] First place image URL: ${route.places.first.imageUrl}', name: 'RouteCard');
      developer.log('[DEBUG] First place rating count: ${route.places.first.ratingCount}', name: 'RouteCard');
    } else {
      developer.log('[DEBUG] No places in this route', name: 'RouteCard');
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section - use improved image handling
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 120,
                width: double.infinity,
                child: route.places.isNotEmpty && route.places.first.imageUrl != null
                ? _buildImageWithFallback(route.places.first.imageUrl!)
                : Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            route.places.isNotEmpty ? getIconForPlaceType(route.places.first.type) : Icons.map,
                            size: 40,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            route.places.isNotEmpty ? route.places.first.name : '경로 이미지',
                            style: TextStyle(color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          routeName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        createdDate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.place_outlined, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '출발: $startPlaceName',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Row(
                    children: [
                      Icon(Icons.flag_outlined, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '도착: $endPlaceName',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            route.estimatedDuration,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.straighten_outlined, size: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            route.totalDistance,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.place_outlined, size: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            '${route.places.length}곳',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // 리뷰 카운트 표시 섹션 추가 - 첫 번째 장소의 리뷰 수 표시
                  if (route.places.isNotEmpty && route.places.first.ratingCount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.rate_review_outlined, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '리뷰 ${route.places.first.ratingCount}개',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (route.places.first.rating != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            '${route.places.first.rating}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build an image with proper error handling
  Widget _buildImageWithFallback(String imageUrl) {
    return Image.network(
      ApiConfig.getImageUrl(imageUrl),
      fit: BoxFit.cover,
      headers: {
        'Authorization': 'Bearer ${ApiConfig.getToken()}',
      },
      errorBuilder: (context, error, stackTrace) {
        developer.log('Error loading image: $error', name: 'RouteCard');
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              size: 40,
              color: Colors.grey[700],
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }

  // Helper method to format date
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  }

  // Helper method to get icon for place type
  IconData getIconForPlaceType(String? type) {
    if (type == null) return Icons.place;

    switch (type.toLowerCase()) {
      case 'restaurant':
      case '식당':
        return Icons.restaurant;
      case 'cafe':
      case '카페':
        return Icons.coffee;
      case 'attraction':
      case '명소':
        return Icons.attractions;
      case 'shopping':
      case '쇼핑':
        return Icons.shopping_bag;
      case 'hotel':
      case '숙소':
        return Icons.hotel;
      case 'landmark':
        return Icons.location_city;
      default:
        return Icons.place;
    }
  }
}