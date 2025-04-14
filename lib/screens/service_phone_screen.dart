import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../models/phone.dart';
import '../providers/phone_provider.dart';
import '../utils/formatters.dart';

class ServicePhoneScreen extends StatefulWidget {
  final Phone phone;

  const ServicePhoneScreen({super.key, required this.phone});

  @override
  State<ServicePhoneScreen> createState() => _ServicePhoneScreenState();
}

class _ServicePhoneScreenState extends State<ServicePhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceNameController = TextEditingController();
  final _serviceCenterNameController = TextEditingController();
  final _serviceCenterPhoneController = TextEditingController();
  final _servicePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing service information if available
    if (widget.phone.serviceName != null) {
      _serviceNameController.text = widget.phone.serviceName!;
    }
    if (widget.phone.serviceCenterName != null) {
      _serviceCenterNameController.text = widget.phone.serviceCenterName!;
    }
    if (widget.phone.serviceCenterPhone != null) {
      _serviceCenterPhoneController.text = widget.phone.serviceCenterPhone!;
    }
    if (widget.phone.servicePrice != null) {
      _servicePriceController.text = widget.phone.servicePrice.toString();
    }
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _serviceCenterNameController.dispose();
    _serviceCenterPhoneController.dispose();
    _servicePriceController.dispose();
    super.dispose();
  }

  void _saveServiceInfo() async {
    if (_formKey.currentState!.validate()) {
      final phoneProvider = Provider.of<PhoneProvider>(context, listen: false);

      double servicePrice = 0.0;
      if (_servicePriceController.text.isNotEmpty) {
        servicePrice = double.parse(_servicePriceController.text);
      }

      await phoneProvider.updateServiceInfo(
        widget.phone.id!,
        _serviceNameController.text.trim(),
        _serviceCenterNameController.text.trim(),
        _serviceCenterPhoneController.text.trim(),
        servicePrice,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Service information updated successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Phone Info Summary
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
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('IMEI: ${widget.phone.imei}'),
                      Text('Color: ${widget.phone.color}'),
                      Text('Capacity: ${widget.phone.capacity}'),
                      Text(
                          'Purchase Price: ${Formatters.formatCurrency(widget.phone.purchasePrice)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section Title
              const Text(
                'Service Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),

              // Service Name
              TextFormField(
                controller: _serviceNameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name *',
                  hintText: 'e.g. Screen Replacement, Battery Replacement',
                  prefixIcon: Icon(Icons.build),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the service name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Service Center Name
              TextFormField(
                controller: _serviceCenterNameController,
                decoration: const InputDecoration(
                  labelText: 'Service Center Name *',
                  hintText: 'e.g. iBox Service, iPhone Care',
                  prefixIcon: Icon(Icons.store),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the service center name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Service Center Phone
              TextFormField(
                controller: _serviceCenterPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Service Center Phone *',
                  hintText: 'e.g. 08123456789',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the service center phone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Service Price
              TextFormField(
                controller: _servicePriceController,
                decoration: const InputDecoration(
                  labelText: 'Service Price *',
                  hintText: 'e.g. 500000',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the service price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Explanation about price
              Card(
                color: const Color.fromARGB(255, 245, 245, 245),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'The service price will be added to the base price of the phone when calculating total cost and profit.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveServiceInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'SAVE SERVICE INFORMATION',
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
