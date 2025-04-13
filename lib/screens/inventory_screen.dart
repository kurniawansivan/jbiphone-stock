import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/phone.dart';
import '../providers/phone_provider.dart';
import '../utils/formatters.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phoneProvider = Provider.of<PhoneProvider>(context);

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
      body: TabBarView(
        controller: _tabController,
        children: [
          // In Stock Tab
          _buildPhoneList(
            context,
            phoneProvider.inStockPhones,
            PhoneStatus.inStock,
          ),

          // On Service Tab
          _buildPhoneList(
            context,
            phoneProvider.onServicePhones,
            PhoneStatus.onService,
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
              status == PhoneStatus.inStock
                  ? 'No phones in stock'
                  : 'No phones on service',
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
      },
      child: ListView.builder(
        itemCount: phones.length,
        itemBuilder: (context, index) {
          final phone = phones[index];
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
                );
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
            );
          },
          tooltip: 'Sell this phone',
        ),
      ],
    );
  }
}
