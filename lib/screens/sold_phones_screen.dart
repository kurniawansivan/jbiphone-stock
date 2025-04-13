import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/phone.dart';
import '../providers/phone_provider.dart';
import '../utils/formatters.dart';
import 'phone_detail_screen.dart';

class SoldPhonesScreen extends StatelessWidget {
  const SoldPhonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneProvider = Provider.of<PhoneProvider>(context);
    final soldPhones = phoneProvider.soldPhones;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sold Phones'),
        automaticallyImplyLeading: false,
      ),
      body: soldPhones.isEmpty
          ? _buildEmptyState()
          : _buildPhonesList(context, soldPhones),
    );
  }

  Widget _buildEmptyState() {
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
    // Sort by sale date, newest first
    final sortedPhones = List<Phone>.from(phones)
      ..sort((a, b) => b.saleDate!.compareTo(a.saleDate!));

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<PhoneProvider>(context, listen: false).loadPhones();
      },
      child: ListView.builder(
        itemCount: sortedPhones.length,
        itemBuilder: (context, index) {
          final phone = sortedPhones[index];
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
                      Text('→'),
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
