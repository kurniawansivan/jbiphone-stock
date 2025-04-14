import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/phone.dart';
import '../providers/phone_provider.dart';
import '../providers/stats_provider.dart';
import '../utils/formatters.dart';

class SellPhoneScreen extends StatefulWidget {
  final Phone phone;

  const SellPhoneScreen({super.key, required this.phone});

  @override
  State<SellPhoneScreen> createState() => _SellPhoneScreenState();
}

class _SellPhoneScreenState extends State<SellPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _buyerNameController = TextEditingController();
  final _buyerPhoneController = TextEditingController();
  final _salePriceController = TextEditingController();
  DateTime _saleDate = DateTime.now();

  @override
  void dispose() {
    _buyerNameController.dispose();
    _buyerPhoneController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _saleDate) {
      setState(() {
        _saleDate = picked;
      });
    }
  }

  double _calculateProfit() {
    if (_salePriceController.text.isNotEmpty) {
      try {
        final salePrice = double.parse(_salePriceController.text);
        // Use getTotalCost() instead of purchasePrice
        return salePrice - widget.phone.getTotalCost();
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  void _sellPhone() async {
    if (_formKey.currentState!.validate()) {
      final phoneProvider = Provider.of<PhoneProvider>(context, listen: false);
      final statsProvider = Provider.of<StatsProvider>(context, listen: false);

      await phoneProvider.markPhoneAsSold(
        widget.phone.id!,
        _buyerNameController.text.trim(),
        _buyerPhoneController.text.trim(),
        _saleDate,
        double.parse(_salePriceController.text),
      );

      // Refresh stats after selling
      await statsProvider.loadAllCurrentStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone sold successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Phone'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Phone Info Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.phone.model,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('IMEI: ${widget.phone.imei}'),
                      Text(
                          'Purchase Price: ${Formatters.formatCurrency(widget.phone.purchasePrice)}'),
                      Text(
                          'Purchase Date: ${Formatters.formatDate(widget.phone.purchaseDate)}'),
                      if (widget.phone.notes != null &&
                          widget.phone.notes!.isNotEmpty)
                        Text('Notes: ${widget.phone.notes}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buyer Info Section
              const Text(
                'Buyer Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Buyer Name
              TextFormField(
                controller: _buyerNameController,
                decoration: const InputDecoration(
                  labelText: 'Buyer Name *',
                  hintText: 'Enter the buyer\'s name',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the buyer\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Buyer Phone
              TextFormField(
                controller: _buyerPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Buyer Phone Number *',
                  hintText: 'e.g. 1234567890',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15), // Changed from 10 to 15
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the buyer\'s phone number';
                  }
                  // Removed phone number length check to allow for different formats
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sale Date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Sale Date *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    Formatters.formatDate(_saleDate),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sale Price
              TextFormField(
                controller: _salePriceController,
                decoration: const InputDecoration(
                  labelText: 'Sale Price *',
                  hintText: 'e.g. 600.00',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the sale price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Trigger a rebuild to update the profit calculation
                  setState(() {});
                },
              ),
              const SizedBox(height: 24),

              // Profit Calculation
              if (_salePriceController.text.isNotEmpty)
                Card(
                  color: _calculateProfit() >= 0
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Profit Calculation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Base purchase price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Purchase Price:'),
                            Text(Formatters.formatCurrency(
                                widget.phone.purchasePrice)),
                          ],
                        ),

                        // Show service cost if applicable
                        if (widget.phone.servicePrice != null &&
                            widget.phone.servicePrice! > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Service Cost:'),
                              Text(Formatters.formatCurrency(
                                  widget.phone.servicePrice!)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Cost:'),
                              Text(
                                Formatters.formatCurrency(
                                    widget.phone.getTotalCost()),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sale Price:'),
                            Text(Formatters.formatCurrency(
                                double.tryParse(_salePriceController.text) ??
                                    0.0)),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Profit:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              Formatters.formatCurrency(_calculateProfit()),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _calculateProfit() >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _sellPhone,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'COMPLETE SALE',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
