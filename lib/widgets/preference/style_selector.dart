import 'package:flutter/material.dart';

class StyleSelector extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final Function(String) onChanged;

  const StyleSelector({
    Key? key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: options.map((option) {
        final isSelected = option == selectedOption;
        return InkWell(
          onTap: () => onChanged(option),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
