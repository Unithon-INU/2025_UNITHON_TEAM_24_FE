import 'package:flutter/material.dart';

class BudgetSlider extends StatelessWidget {
  final String selectedBudget;
  final Function(String) onChanged;
  final List<String> budgetOptions = ['매우 저렴', '저렴', '중간', '고급', '매우 고급'];

  BudgetSlider({
    Key? key,
    required this.selectedBudget,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int currentIndex = budgetOptions.indexOf(selectedBudget);
    
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Colors.grey[300],
            trackHeight: 4.0,
            thumbColor: Theme.of(context).primaryColor,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
            overlayColor: Theme.of(context).primaryColor.withAlpha(60),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0),
          ),
          child: Slider(
            value: currentIndex.toDouble(),
            min: 0,
            max: budgetOptions.length - 1.0,
            divisions: budgetOptions.length - 1,
            onChanged: (value) {
              onChanged(budgetOptions[value.toInt()]);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('매우 저렴', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text('매우 고급', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              selectedBudget,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}