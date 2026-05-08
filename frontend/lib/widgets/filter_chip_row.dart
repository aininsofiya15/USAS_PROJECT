import 'package:flutter/material.dart';

class FilterChipRow extends StatelessWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;

  const FilterChipRow({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'value': 'all', 'label': 'All', 'color': Colors.grey},
      {'value': 'paid', 'label': 'Paid', 'color': Colors.green},
      {'value': 'unpaid', 'label': 'Unpaid', 'color': Colors.orange},
      {'value': 'blocked', 'label': 'Blocked', 'color': Colors.red},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = currentFilter == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onFilterChanged(filter['value'] as String);
                }
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: (filter['color'] as Color).withOpacity(0.2),
              checkmarkColor: filter['color'] as Color?,
              labelStyle: TextStyle(
                color: isSelected ? (filter['color'] as Color) : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}