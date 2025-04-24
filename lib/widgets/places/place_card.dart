// lib/widgets/places/place_card.dart
import 'package:flutter/material.dart';
import '../../models/place.dart';
import '../../config/api_config.dart';  // Import ApiConfig

class PlaceCard extends StatelessWidget {
  final Place place;
  final int? index; // Optional index to show numbering (1-based)
  final VoidCallback? onTap;

  const PlaceCard({
    Key? key,
    required this.place,
    this.index,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Index circle (if provided)
              if (index != null)
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      index.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              // Place image (if available)
              if (place.imageUrl != null)
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      ApiConfig.baseUrl + place.imageUrl!,
                      fit: BoxFit.cover,
                      headers: {
                        'Authorization': 'Bearer ${ApiConfig.getToken()}',
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _getPlaceIcon(place.type ?? 'place'),
                          color: Colors.grey[600],
                          size: 30,
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    _getPlaceIcon(place.type ?? 'place'),
                    color: Colors.grey[600],
                    size: 30,
                  ),
                ),
              
              // Place information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.address ?? '주소 정보 없음', // Add fallback value
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${place.rating ?? 0} (${place.ratingCount ?? 0})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        _buildTag(context, place.type ?? 'place'), // Add fallback value
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action icon
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
  
  // Get appropriate icon based on place type
  IconData _getPlaceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'restaurant':
      case '식당':
      case 'food':
        return Icons.restaurant;
      case 'cafe':
      case '카페':
        return Icons.local_cafe;
      case 'shopping':
      case '쇼핑':
        return Icons.shopping_bag;
      case 'attraction':
      case '명소':
      case 'landmark':
        return Icons.photo_camera;
      case 'hotel':
      case '숙소':
        return Icons.hotel;
      default:
        return Icons.place;
    }
  }
  
  // Build tag chip for place type
  Widget _buildTag(BuildContext context, String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getTagColor(tag),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  // Get tag color based on place type
  Color _getTagColor(String type) {
    switch (type.toLowerCase()) {
      case 'restaurant':
      case '식당':
      case 'food':
        return Colors.redAccent;
      case 'cafe':
      case '카페':
        return Colors.brown;
      case 'shopping':
      case '쇼핑':
        return Colors.purpleAccent;
      case 'attraction':
      case '명소':
      case 'landmark':
        return Colors.blueAccent;
      case 'hotel':
      case '숙소':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}