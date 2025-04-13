import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/phone.dart';
import '../providers/phone_provider.dart';
import '../utils/formatters.dart';
import '../widgets/search_filter_bar.dart';
import 'phone_detail_screen.dart';
import 'sell_phone_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;
  List<Phone> _filteredInStockPhones = [];
  List<Phone> _filteredOnServicePhones = [];

  final List<FilterOption> _filterOptions = [
    FilterOption(label: 'All', value: 'all'),
    FilterOption(label: 'Model', value: 'model'),
    FilterOption(label: 'IMEI', value: 'imei'),
    FilterOption(label: 'Price: Low to High', value: 'price_asc'),
    FilterOption(label: 'Price: High to Low', value: 'price_desc'),
    FilterOption(label: 'Date: Newest', value: 'date_desc'),
    FilterOption(label: 'Date: Oldest', value: 'date_asc'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedFilter = 'all';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFilteredLists();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterPhones(String query) {
    setState(() {
      _updateFilteredLists();
    });
  }

  void _updateFilteredLists() {
    final phoneProvider = Provider.of<PhoneProvider>(context, listen: false);
    final query = _searchController.text.toLowerCase();

    // Filter in stock phones
    _filteredInStockPhones = phoneProvider.inStockPhones.where((phone) {
      bool matchesSearch = true;

      if (query.isNotEmpty) {
        matchesSearch = phone.model.toLowerCase().contains(query) ||
            phone.imei.toLowerCase().contains(query) ||
            (phone.notes?.toLowerCase().contains(query) ?? false);
      }

      return matchesSearch;
    }).toList();

    // Filter on service phones
    _filteredOnServicePhones = phoneProvider.onServicePhones.where((phone) {
      bool matchesSearch = true;

      if (query.isNotEmpty) {
        matchesSearch = phone.model.toLowerCase().contains(query) ||
            phone.imei.toLowerCase().contains(query) ||
            (phone.notes?.toLowerCase().contains(query) ?? false);
      }

      return matchesSearch;
    }).toList();

    // Apply sorting based on selected filter
    _applySorting(_filteredInStockPhones);
    _applySorting(_filteredOnServicePhones);
  }

  void _applySorting(List<Phone> phones) {
    switch (_selectedFilter) {
      case 'price_asc':
        phones.sort((a, b) => a.purchasePrice.compareTo(b.purchasePrice));
        break;
      case 'price_desc':
        phones.sort((a, b) => b.purchasePrice.compareTo(a.purchasePrice));
        break;
      case 'date_desc':
        phones.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
        break;
      case 'date_asc':
        phones.sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));
        break;
      case 'model':
        phones.sort((a, b) => a.model.compareTo(b.model));
        break;
      case 'imei':
        phones.sort((a, b) => a.imei.compareTo(b.imei));
        break;
      case 'all':
      default:
        // Default sorting by date (newest first)
        phones.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final phoneProvider = Provider.of<PhoneProvider>(context);

    // Update filtered lists when phone data changes
    if (_filteredInStockPhones.isEmpty && _filteredOnServicePhones.isEmpty) {
      _updateFilteredLists();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'In Stock'),
            Tab(text: 'On Service'),
          ],
        ),
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
                _updateFilteredLists();
              });
            },
            searchHint: 'Search by model, IMEI or notes',
            onChanged: (value) {},
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // In Stock Tab
                _buildPhoneList(
                  context,
                  _filteredInStockPhones,
                  PhoneStatus.inStock,
                ),

                // On Service Tab
                _buildPhoneList(
                  context,
                  _filteredOnServicePhones,
                  PhoneStatus.onService,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneList(
      BuildContext context, List<Phone> phones, PhoneStatus status) {
    if (phones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == PhoneStatus.inStock ? Icons.phone_iphone : Icons.build,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No matching phones found'
                  : (status == PhoneStatus.inStock
                      ? 'No phones in stock'
                      : 'No phones on service'),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<PhoneProvider>(context, listen: false).loadPhones();
        _updateFilteredLists();
      },
      child: ListView.builder(
        itemCount: phones.length,
        itemBuilder: (context, index) {
          final phone = phones[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(
                "${phone.model} - ${phone.capacity} ${phone.color}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('IMEI: ${phone.imei}'),
                  Text(
                      'Purchase: ${Formatters.formatCurrency(phone.purchasePrice)}'),
                  Text('Date: ${Formatters.formatDate(phone.purchaseDate)}'),
                ],
              ),
              trailing: _buildActionButtons(context, phone),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhoneDetailScreen(phone: phone),
                  ),
                ).then((_) => _updateFilteredLists());
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Phone phone) {
    final phoneProvider = Provider.of<PhoneProvider>(context, listen: false);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toggle service status button
        IconButton(
          icon: Icon(
            phone.status == PhoneStatus.inStock ? Icons.build : Icons.check,
            color: phone.status == PhoneStatus.inStock
                ? Colors.orange
                : Colors.green,
          ),
          onPressed: () async {
            if (phone.status == PhoneStatus.inStock) {
              await phoneProvider.markPhoneAsOnService(phone.id!);
            } else {
              await phoneProvider.markPhoneAsInStock(phone.id!);
            }
            _updateFilteredLists();
          },
          tooltip: phone.status == PhoneStatus.inStock
              ? 'Mark as on service'
              : 'Mark as in stock',
        ),

        // Sell button
        IconButton(
          icon: const Icon(Icons.attach_money, color: Colors.green),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SellPhoneScreen(phone: phone),
              ),
            ).then((_) => _updateFilteredLists());
          },
          tooltip: 'Sell this phone',
        ),
      ],
    );
  }
}
