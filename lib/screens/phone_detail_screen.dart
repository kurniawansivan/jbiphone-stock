import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/phone.dart';
import '../providers/phone_provider.dart';
import '../providers/stats_provider.dart';
import '../utils/formatters.dart';
import 'sell_phone_screen.dart';
import 'service_phone_screen.dart';

class PhoneDetailScreen extends StatelessWidget {
  final Phone phone;

  const PhoneDetailScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    final phoneProvider = Provider.of<PhoneProvider>(context);

    String getStatusText(PhoneStatus status) {
      switch (status) {
        case PhoneStatus.inStock:
          return 'In Stock';
        case PhoneStatus.onService:
          return 'On Service';
        case PhoneStatus.sold:
          return 'Sold';
      }
    }

    Color getStatusColor(PhoneStatus status) {
      switch (status) {
        case PhoneStatus.inStock:
          return Colors.green;
        case PhoneStatus.onService:
          return Colors.orange;
        case PhoneStatus.sold:
          return Colors.blue;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(phone.model),
        actions: [
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: const Text(
                      'Are you sure you want to delete this phone record?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await phoneProvider.deletePhone(phone.id!);
                        if (context.mounted) {
                          // Also refresh stats
                          await Provider.of<StatsProvider>(context,
                                  listen: false)
                              .loadAllCurrentStats();
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Go back to previous screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Phone deleted successfully')),
                          );
                        }
                      },
                      child: const Text('DELETE'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Delete phone',
          ),
        ],
      ),
      floatingActionButton: phone.status != PhoneStatus.sold
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SellPhoneScreen(phone: phone),
                  ),
                );
              },
              child: const Icon(Icons.attach_money),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              elevation: 2,
              color: getStatusColor(phone.status).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      phone.status == PhoneStatus.inStock
                          ? Icons.check_circle
                          : phone.status == PhoneStatus.onService
                              ? Icons.build
                              : Icons.attach_money,
                      color: getStatusColor(phone.status),
                      size: 36,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          getStatusText(phone.status),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(phone.status),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Phone Details Section
            const Text(
              'Phone Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),

            // Phone model
            _buildDetailRow('Model', phone.model),

            // Color
            _buildDetailRow('Color', phone.color),

            // Capacity
            _buildDetailRow('Capacity', phone.capacity),

            // IMEI
            _buildDetailRow('IMEI', phone.imei),

            // Purchase Date
            _buildDetailRow(
                'Purchase Date', Formatters.formatDate(phone.purchaseDate)),

            // Purchase Price
            _buildDetailRow('Purchase Price',
                Formatters.formatCurrency(phone.purchasePrice)),

            // Total Cost (Purchase Price + Service Price)
            if (phone.servicePrice != null && phone.servicePrice! > 0)
              _buildDetailRow(
                'Total Cost',
                Formatters.formatCurrency(phone.getTotalCost()),
                valueColor: Colors.red,
              ),

            // Notes
            if (phone.notes != null && phone.notes!.isNotEmpty)
              _buildDetailRow('Notes', phone.notes!),

            const SizedBox(height: 16),

            // Seller Information Section
            const Text(
              'Seller Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),

            // Seller Name
            _buildDetailRow('Seller Name', phone.sellerName),

            // Seller Phone
            _buildDetailRow('Seller Phone', phone.sellerPhone),

            const SizedBox(height: 16),

            // Service Information Section (Only for onService phones or when service info exists)
            if (phone.status == PhoneStatus.onService ||
                phone.serviceName != null) ...[
              const Text(
                'Service Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),

              // Service Name
              if (phone.serviceName != null)
                _buildDetailRow('Service Name', phone.serviceName!),

              // Service Center
              if (phone.serviceCenterName != null)
                _buildDetailRow('Service Center', phone.serviceCenterName!),

              // Service Center Phone
              if (phone.serviceCenterPhone != null)
                _buildDetailRow(
                    'Service Center Phone', phone.serviceCenterPhone!),

              // Service Price
              if (phone.servicePrice != null)
                _buildDetailRow('Service Price',
                    Formatters.formatCurrency(phone.servicePrice!)),
            ],

            // Buyer Information Section (Only for sold phones)
            if (phone.status == PhoneStatus.sold) ...[
              const SizedBox(height: 16),
              const Text(
                'Buyer Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),

              // Buyer Name
              _buildDetailRow('Buyer Name', phone.buyerName!),

              // Buyer Phone
              _buildDetailRow('Buyer Phone',
                  Formatters.formatPhoneNumber(phone.buyerPhone!)),

              // Sale Date
              _buildDetailRow(
                  'Sale Date', Formatters.formatDate(phone.saleDate!)),

              // Sale Price
              _buildDetailRow(
                  'Sale Price', Formatters.formatCurrency(phone.salePrice!)),

              // Profit
              _buildDetailRow(
                'Profit',
                Formatters.formatCurrency(phone.getProfit()!),
                valueColor: phone.getProfit()! >= 0 ? Colors.green : Colors.red,
              ),
            ],

            // Status Change Buttons
            if (phone.status != PhoneStatus.sold) ...[
              const SizedBox(height: 24),
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (phone.status == PhoneStatus.inStock)
                    ElevatedButton.icon(
                      onPressed: () async {
                        await phoneProvider.markPhoneAsOnService(phone.id!);

                        if (context.mounted) {
                          // Navigate to service form
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ServicePhoneScreen(phone: phone),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.build),
                      label: const Text('Mark as On Service'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else if (phone.status == PhoneStatus.onService) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ServicePhoneScreen(phone: phone),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Service Info'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await phoneProvider.markPhoneAsInStock(phone.id!);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Mark as In Stock'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellPhoneScreen(phone: phone),
                        ),
                      );
                    },
                    icon: const Icon(Icons.attach_money),
                    label: const Text('Sell Phone'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
