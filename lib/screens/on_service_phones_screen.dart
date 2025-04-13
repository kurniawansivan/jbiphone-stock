import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/phone.dart';
import '../providers/phone_provider.dart';
import '../utils/formatters.dart';
import 'phone_detail_screen.dart';
import 'service_phone_screen.dart';
import '../widgets/search_filter_bar.dart';

class OnServicePhonesScreen extends StatelessWidget {
  const OnServicePhonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phones On Service'),
      ),
      body: Column(
        children: [
          // Search filter bar
          SearchFilterBar(
            onChanged: (value) {
              Provider.of<PhoneProvider>(context, listen: false)
                  .loadPhones(); // You could implement specific filtering here
            },
          ),

          // List of phones on service
          Expanded(
            child: Consumer<PhoneProvider>(
              builder: (context, phoneProvider, child) {
                final phones = phoneProvider.onServicePhones;

                if (phones.isEmpty) {
                  return const Center(
                    child: Text('No phones currently on service'),
                  );
                }

                return ListView.builder(
                  itemCount: phones.length,
                  itemBuilder: (context, index) {
                    final phone = phones[index];
                    return _buildServicePhoneCard(context, phone);
                  },
                );
              },
            ),
          ),
        ],
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
          );
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
                      );
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
