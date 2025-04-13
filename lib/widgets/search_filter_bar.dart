import 'package:flutter/material.dart';

class SearchFilterBar extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final List<FilterOption> filterOptions;
  final String? selectedFilter;
  final Function(String?) onFilterChanged;
  final String searchHint;

  const SearchFilterBar({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.filterOptions,
    this.selectedFilter,
    required this.onFilterChanged,
    this.searchHint = 'Search...',
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            // Search Icon
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),

            // Search TextField
            Expanded(
              child: TextField(
                controller: widget.searchController,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  border: InputBorder.none,
                ),
                onChanged: widget.onSearch,
              ),
            ),

            // Filter dropdown
            DropdownButton<String>(
              value: widget.selectedFilter,
              underline: const SizedBox(),
              icon: const Icon(Icons.filter_list),
              onChanged: widget.onFilterChanged,
              items: widget.filterOptions.map((FilterOption option) {
                return DropdownMenuItem<String>(
                  value: option.value,
                  child: Text(option.label),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterOption {
  final String label;
  final String value;

  FilterOption({required this.label, required this.value});
}
