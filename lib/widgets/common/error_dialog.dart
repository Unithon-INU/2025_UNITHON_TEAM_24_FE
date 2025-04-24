import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorDialog({
    Key? key,
    this.title = '오류 발생',
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (onRetry != null) ...[
            SizedBox(height: 16),
            Text(
              '다시 시도하시겠습니까?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('닫기'),
        ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: Text('다시 시도'),
          ),
      ],
    );
  }

  // 다이얼로그 표시 메서드
  static void show(BuildContext context, String message, {VoidCallback? onRetry}) {
    showDialog(
      context: context,
      builder: (ctx) => ErrorDialog(
        message: message,
        onRetry: onRetry,
      ),
    );
  }
}
