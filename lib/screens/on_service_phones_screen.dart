import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/phone.dart';
import '../providers/phone_provider.dart';
import '../utils/formatters.dart';
import 'phone_detail_screen.dart';
import 'service_phone_screen.dart';
import '../widgets/search_filter_bar.dart';

class OnServicePhonesScreen extends StatefulWidget {
  const OnServicePhonesScreen({super.key});

  @override
  State<OnServicePhonesScreen> createState() => _OnServicePhonesScreenState();
}

class _OnServicePhonesScreenState extends State<OnServicePhonesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;
  List<Phone> _filteredServicePhones = [];

  final List<FilterOption> _filterOptions = [
    FilterOption(label: 'All', value: 'all'),
    FilterOption(label: 'Model', value: 'model'),
    FilterOption(label: 'Service Name', value: 'service'),
    FilterOption(label: 'Service Center', value: 'center'),
    FilterOption(label: 'Service Price: Low to High', value: 'price_asc'),
    FilterOption(label: 'Service Price: High to Low', value: 'price_desc'),
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

    _filteredServicePhones = phoneProvider.onServicePhones.where((phone) {
      bool matchesSearch = true;

      if (query.isNotEmpty) {
        matchesSearch = phone.model.toLowerCase().contains(query) ||
            phone.imei.toLowerCase().contains(query) ||
            (phone.serviceName?.toLowerCase().contains(query) ?? false) ||
            (phone.serviceCenterName?.toLowerCase().contains(query) ?? false) ||
            (phone.notes?.toLowerCase().contains(query) ?? false);
      }

      return matchesSearch;
    }).toList();

    // Apply sorting based on selected filter
    _applySorting();
  }

  void _applySorting() {
    switch (_selectedFilter) {
      case 'price_asc':
        _filteredServicePhones.sort(
            (a, b) => (a.servicePrice ?? 0).compareTo(b.servicePrice ?? 0));
        break;
      case 'price_desc':
        _filteredServicePhones.sort(
            (a, b) => (b.servicePrice ?? 0).compareTo(a.servicePrice ?? 0));
        break;
      case 'date_desc':
        _filteredServicePhones
            .sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
        break;
      case 'date_asc':
        _filteredServicePhones
            .sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));
        break;
      case 'model':
        _filteredServicePhones.sort((a, b) => a.model.compareTo(b.model));
        break;
      case 'service':
        _filteredServicePhones.sort(
            (a, b) => (a.serviceName ?? '').compareTo(b.serviceName ?? ''));
        break;
      case 'center':
        _filteredServicePhones.sort((a, b) =>
            (a.serviceCenterName ?? '').compareTo(b.serviceCenterName ?? ''));
        break;
      case 'all':
      default:
        // Default sorting by date (newest first)
        _filteredServicePhones
            .sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final phoneProvider = Provider.of<PhoneProvider>(context);

    // Update filtered list when phone data changes
    if (_filteredServicePhones.isEmpty &&
        phoneProvider.onServicePhones.isNotEmpty) {
      _updateFilteredList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phones On Service'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search filter bar
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
            searchHint: 'Search by model, service, or IMEI',
            onChanged: (value) {},
          ),

          // List of phones on service
          Expanded(
            child: _filteredServicePhones.isEmpty
                ? _buildEmptyState()
                : _buildServicePhonesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isNotEmpty) {
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
              'No matching phones found',
              style: TextStyle(
                fontSize: 18,
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
            Icons.build,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No phones currently on service',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicePhonesList() {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<PhoneProvider>(context, listen: false).loadPhones();
        _updateFilteredList();
      },
      child: ListView.builder(
        itemCount: _filteredServicePhones.length,
        itemBuilder: (context, index) {
          return _buildServicePhoneCard(context, _filteredServicePhones[index]);
        },
      ),
    );
  }

  Widget _buildServicePhoneCard(BuildContext context, Phone phone) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneDetailScreen(phone: phone),
            ),
          ).then((_) => _updateFilteredList());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phone model and IMEI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      phone.model,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'On Service',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('IMEI: ${phone.imei}'),
              Text('Color: ${phone.color} | Capacity: ${phone.capacity}'),
              const Divider(),

              // Display service information if available
              if (phone.serviceName != null) ...[
                Text(
                  'Service: ${phone.serviceName!}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (phone.serviceCenterName != null)
                  Text('Service Center: ${phone.serviceCenterName!}'),
                if (phone.servicePrice != null)
                  Text(
                      'Service Price: ${Formatters.formatCurrency(phone.servicePrice!)}'),
              ] else
                const Text('No service details recorded'),

              // Action buttons
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Edit Service Info button
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ServicePhoneScreen(phone: phone),
                        ),
                      ).then((_) => _updateFilteredList());
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Service'),
                  ),

                  // Mark as in stock button
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Status Change'),
                          content: const Text(
                              'Return this phone to in-stock inventory?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await Provider.of<PhoneProvider>(context,
                                        listen: false)
                                    .markPhoneAsInStock(phone.id!);
                                if (context.mounted) {
                                  Navigator.pop(context); // Close dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Phone marked as in stock'),
                                    ),
                                  );
                                  _updateFilteredList();
                                }
                              },
                              child: const Text('CONFIRM'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle,
                        size: 18, color: Colors.green),
                    label: const Text('Return to Stock'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
