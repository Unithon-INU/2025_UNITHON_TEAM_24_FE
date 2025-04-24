import 'package:flutter/material.dart';
import 'package:unithon/models/review.dart';

class ReviewList extends StatelessWidget {
  final List<Review> reviews;

  const ReviewList({
    Key? key,
    required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                '아직 리뷰가 없습니다.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 작성자 정보 및 평점
                  Row(
                    children: [
                      if (review.profilePhotoUrl != null)
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(review.profilePhotoUrl!),
                          onBackgroundImageError: (e, s) => const Icon(Icons.person),
                        )
                      else
                        const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.person, size: 20),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.authorName ?? '익명',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (review.relativeTimeDescription != null)
                              Text(
                                review.relativeTimeDescription!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // 평점
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber[700], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              review.rating.toString(),
                              style: TextStyle(
                                color: Colors.amber[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 리뷰 내용
                  if (review.text?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 12),
                    Text(
                      review.text!,
                      style: const TextStyle(
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}