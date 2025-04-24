import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int ratingCount;
  final double size;
  final bool showText;
  final MainAxisAlignment alignment;

  const StarRating({
    Key? key,
    required this.rating,
    required this.ratingCount,
    this.size = 16.0,
    this.showText = true,
    this.alignment = MainAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          itemSize: size,
          direction: Axis.horizontal,
        ),
        if (showText) ...[  
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            '($ratingCount)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}