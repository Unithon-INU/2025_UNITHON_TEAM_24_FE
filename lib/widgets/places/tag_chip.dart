import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String label;
  const TagChip({required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}