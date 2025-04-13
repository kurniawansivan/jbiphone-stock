import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/phone.dart';
import '../providers/phone_provider.dart';
import '../utils/formatters.dart';

class AddPhoneScreen extends StatefulWidget {
  const AddPhoneScreen({super.key});

  @override
  State<AddPhoneScreen> createState() => _AddPhoneScreenState();
}

class _AddPhoneScreenState extends State<AddPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _imeiController = TextEditingController();
  final _priceController = TextEditingController();
  final _colorController = TextEditingController();
  final _capacityController = TextEditingController();
  final _sellerNameController = TextEditingController();
  final _sellerPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _purchaseDate = DateTime.now();
  PhoneStatus _initialStatus = PhoneStatus.inStock;

  @override
  void dispose() {
    _modelController.dispose();
    _imeiController.dispose();
    _priceController.dispose();
    _colorController.dispose();
    _capacityController.dispose();
    _sellerNameController.dispose();
    _sellerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  void _savePhone() async {
    if (_formKey.currentState!.validate()) {
      final phoneProvider = Provider.of<PhoneProvider>(context, listen: false);

      final phone = Phone(
        model: _modelController.text.trim(),
        imei: _imeiController.text.trim(),
        purchaseDate: _purchaseDate,
        purchasePrice: double.parse(_priceController.text),
        color: _colorController.text.trim(),
        capacity: _capacityController.text.trim(),
        sellerName: _sellerNameController.text.trim(),
        sellerPhone: _sellerPhoneController.text.trim(),
        notes: _notesController.text.trim(),
        status: _initialStatus,
      );

      await phoneProvider.addPhone(phone);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone added successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Phone'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section Title - Phone Details
              const Text(
                'Phone Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),

              // Model
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'iPhone Model *',
                  hintText: 'e.g. iPhone 13 Pro, iPhone 14',
                  prefixIcon: Icon(Icons.phone_iphone),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the iPhone model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // IMEI
              TextFormField(
                controller: _imeiController,
                decoration: const InputDecoration(
                  labelText: 'IMEI Number *',
                  hintText: 'e.g. 123456789012345',
                  prefixIcon: Icon(Icons.pin),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the IMEI number';
                  }
                  if (value.length < 15) {
                    return 'IMEI should be 15 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Color
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Phone Color *',
                  hintText: 'e.g. Black, Silver, Gold',
                  prefixIcon: Icon(Icons.color_lens),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the phone color';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Capacity
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Storage Capacity *',
                  hintText: 'e.g. 64GB, 128GB, 256GB',
                  prefixIcon: Icon(Icons.sd_storage),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the storage capacity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Purchase Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Purchase Price *',
                  hintText: 'e.g. 5000000',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the purchase price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Purchase Date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Purchase Date *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    Formatters.formatDate(_purchaseDate),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Section Title - Seller Information
              const Text(
                'Seller Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),

              // Seller Name
              TextFormField(
                controller: _sellerNameController,
                decoration: const InputDecoration(
                  labelText: 'Seller Name *',
                  hintText: 'Enter the seller\'s name',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the seller\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Seller Phone
              TextFormField(
                controller: _sellerPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Seller Phone Number *',
                  hintText: 'e.g. 08123456789',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the seller\'s phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Section Title - Additional Information
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),

              // Initial Status
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Initial Status *',
                  prefixIcon: Icon(Icons.category),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PhoneStatus>(
                    value: _initialStatus,
                    isDense: true,
                    isExpanded: true,
                    onChanged: (PhoneStatus? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _initialStatus = newValue;
                        });
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: PhoneStatus.inStock,
                        child: const Text('In Stock'),
                      ),
                      DropdownMenuItem(
                        value: PhoneStatus.onService,
                        child: const Text('On Service'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Any additional information',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _savePhone,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'ADD PHONE',
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
