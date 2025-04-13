import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/phone.dart';
import '../providers/phone_provider.dart';
import '../utils/formatters.dart';
import '../widgets/search_filter_bar.dart';
import 'phone_detail_screen.dart';

class SoldPhonesScreen extends StatefulWidget {
  const SoldPhonesScreen({super.key});

  @override
  State<SoldPhonesScreen> createState() => _SoldPhonesScreenState();
}

class _SoldPhonesScreenState extends State<SoldPhonesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;
  List<Phone> _filteredSoldPhones = [];
  DateTime? _startDate;
  DateTime? _endDate;

  final List<FilterOption> _filterOptions = [
    FilterOption(label: 'All', value: 'all'),
    FilterOption(label: 'Model', value: 'model'),
    FilterOption(label: 'Buyer', value: 'buyer'),
    FilterOption(label: 'Sale Price: Low to High', value: 'sale_price_asc'),
    FilterOption(label: 'Sale Price: High to Low', value: 'sale_price_desc'),
    FilterOption(label: 'Profit: Low to High', value: 'profit_asc'),
    FilterOption(label: 'Profit: High to Low', value: 'profit_desc'),
    FilterOption(label: 'Date: Newest', value: 'date_desc'),
    FilterOption(label: 'Date: Oldest', value: 'date_asc'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = 'date_desc';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFilteredList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPhones(String query) {
    setState(() {
      _updateFilteredList();
    });
  }

  void _updateFilteredList() {
    final phoneProvider = Provider.of<PhoneProvider>(context, listen: false);
    final query = _searchController.text.toLowerCase();

    _filteredSoldPhones = phoneProvider.soldPhones.where((phone) {
      // Apply search filter
      bool matchesSearch = true;
      if (query.isNotEmpty) {
        matchesSearch = phone.model.toLowerCase().contains(query) ||
            phone.imei.toLowerCase().contains(query) ||
            (phone.buyerName?.toLowerCase().contains(query) ?? false) ||
            (phone.buyerPhone?.toLowerCase().contains(query) ?? false) ||
            (phone.notes?.toLowerCase().contains(query) ?? false);
      }

      // Apply date range filter
      bool matchesDateRange = true;
      if (_startDate != null) {
        matchesDateRange = phone.saleDate!.isAfter(_startDate!) ||
            phone.saleDate!.isAtSameMomentAs(_startDate!);
      }
      if (_endDate != null) {
        final endOfDay = DateTime(
            _endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        matchesDateRange = matchesDateRange &&
            (phone.saleDate!.isBefore(endOfDay) ||
                phone.saleDate!.isAtSameMomentAs(endOfDay));
      }

      return matchesSearch && matchesDateRange;
    }).toList();

    // Apply sorting
    _applySorting();
  }

  void _applySorting() {
    switch (_selectedFilter) {
      case 'sale_price_asc':
        _filteredSoldPhones
            .sort((a, b) => a.salePrice!.compareTo(b.salePrice!));
        break;
      case 'sale_price_desc':
        _filteredSoldPhones
            .sort((a, b) => b.salePrice!.compareTo(a.salePrice!));
        break;
      case 'profit_asc':
        _filteredSoldPhones
            .sort((a, b) => (a.getProfit() ?? 0).compareTo(b.getProfit() ?? 0));
        break;
      case 'profit_desc':
        _filteredSoldPhones
            .sort((a, b) => (b.getProfit() ?? 0).compareTo(a.getProfit() ?? 0));
        break;
      case 'date_desc':
        _filteredSoldPhones.sort((a, b) => b.saleDate!.compareTo(a.saleDate!));
        break;
      case 'date_asc':
        _filteredSoldPhones.sort((a, b) => a.saleDate!.compareTo(b.saleDate!));
        break;
      case 'model':
        _filteredSoldPhones.sort((a, b) => a.model.compareTo(b.model));
        break;
      case 'buyer':
        _filteredSoldPhones
            .sort((a, b) => (a.buyerName ?? '').compareTo(b.buyerName ?? ''));
        break;
      case 'all':
      default:
        // Default sort by date (newest first)
        _filteredSoldPhones.sort((a, b) => b.saleDate!.compareTo(a.saleDate!));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final phoneProvider = Provider.of<PhoneProvider>(context);

    // Update filtered list when sold phones data changes
    if (_filteredSoldPhones.isEmpty && phoneProvider.soldPhones.isNotEmpty) {
      _updateFilteredList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sold Phones'),
        automaticallyImplyLeading: false,
        actions: [
          // Date range filter button
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _showDateRangeDialog(context),
            tooltip: 'Filter by date range',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          SearchFilterBar(
            searchController: _searchController,
            onSearch: _filterPhones,
            filterOptions: _filterOptions,
            selectedFilter: _selectedFilter,
            onFilterChanged: (value) {
              setState(() {
                _selectedFilter = value;
                _updateFilteredList();
              });
            },
            searchHint: 'Search by model, buyer name or IMEI',
            onChanged: (value) {
              setState(() {
                // Refresh the screen
              });
            },
          ),

          // Date range indicator (if active)
          if (_startDate != null || _endDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Date filter: ${_formatDateRange()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                        _updateFilteredList();
                      });
                    },
                    child: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),

          // Phone list
          Expanded(
            child: _filteredSoldPhones.isEmpty
                ? _buildEmptyState()
                : _buildPhonesList(context, _filteredSoldPhones),
          ),
        ],
      ),
    );
  }

  String _formatDateRange() {
    if (_startDate != null && _endDate != null) {
      return '${Formatters.formatDate(_startDate!)} - ${Formatters.formatDate(_endDate!)}';
    } else if (_startDate != null) {
      return 'From ${Formatters.formatDate(_startDate!)}';
    } else if (_endDate != null) {
      return 'Until ${Formatters.formatDate(_endDate!)}';
    }
    return '';
  }

  Future<void> _showDateRangeDialog(BuildContext context) async {
    DateTime? initialStartDate = _startDate;
    DateTime? initialEndDate = _endDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter by Date'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Start Date Selector
                  ListTile(
                    title: Text(
                      initialStartDate != null
                          ? 'Start Date: ${Formatters.formatDate(initialStartDate!)}'
                          : 'Select Start Date',
                    ),
                    trailing: initialStartDate != null
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setState(() => initialStartDate = null),
                          )
                        : const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: initialStartDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => initialStartDate = picked);
                      }
                    },
                  ),

                  // End Date Selector
                  ListTile(
                    title: Text(
                      initialEndDate != null
                          ? 'End Date: ${Formatters.formatDate(initialEndDate!)}'
                          : 'Select End Date',
                    ),
                    trailing: initialEndDate != null
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setState(() => initialEndDate = null),
                          )
                        : const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: initialEndDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => initialEndDate = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('APPLY'),
                ),
              ],
            );
          },
        );
      },
    ).then((value) {
      if (value == true) {
        setState(() {
          _startDate = initialStartDate;
          _endDate = initialEndDate;
          _updateFilteredList();
        });
      }
    });
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isNotEmpty ||
        _startDate != null ||
        _endDate != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No matching sold phones found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.sell_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No phones have been sold yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhonesList(BuildContext context, List<Phone> phones) {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<PhoneProvider>(context, listen: false).loadPhones();
        _updateFilteredList();
      },
      child: ListView.builder(
        itemCount: phones.length,
        itemBuilder: (context, index) {
          final phone = phones[index];
          final profit = phone.getProfit();

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(
                phone.model,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sold to: ${phone.buyerName}'),
                  Text('Sale date: ${Formatters.formatDate(phone.saleDate!)}'),
                  Row(
                    children: [
                      Text(
                          'Purchase: ${Formatters.formatCurrency(phone.purchasePrice)}'),
                      const SizedBox(width: 8),
                      const Text('→'),
                      const SizedBox(width: 8),
                      Text(
                        'Sale: ${Formatters.formatCurrency(phone.salePrice!)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    'Profit: ${Formatters.formatCurrency(profit!)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: profit > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhoneDetailScreen(phone: phone),
                    ),
                  );
                },
                tooltip: 'View details',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhoneDetailScreen(phone: phone),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
