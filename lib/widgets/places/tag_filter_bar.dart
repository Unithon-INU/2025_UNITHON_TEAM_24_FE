import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tag_filter_provider.dart';

class TagFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tagProvider = Provider.of<TagFilterProvider>(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tagProvider.availableTags.map((tag) {
          final selected = tagProvider.selectedTags.contains(tag);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(tag),
              selected: selected,
              onSelected: (_) => tagProvider.toggleTag(tag),
            ),
          );
        }).toList(),
      ),
    );
  }
}