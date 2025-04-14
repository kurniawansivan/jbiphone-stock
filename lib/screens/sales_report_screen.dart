import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/phone.dart';
import '../providers/phone_provider.dart';
import '../utils/pdf_report_generator.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  String _reportType = 'daily';
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isGenerating = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Type Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Radio buttons for report types
                    _buildReportTypeRadio('Daily', 'daily'),
                    _buildReportTypeRadio('Monthly', 'monthly'),
                    _buildReportTypeRadio('Yearly', 'yearly'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date Selector based on report type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Period',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_reportType == 'daily') _buildDailySelector(),
                    if (_reportType == 'monthly') _buildMonthlySelector(),
                    if (_reportType == 'yearly') _buildYearlySelector(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Generate Report Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateReport,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ))
                    : const Icon(Icons.picture_as_pdf),
                label: Text(
                    _isGenerating ? 'Generating...' : 'Generate PDF Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('Error')
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeRadio(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _reportType,
      onChanged: (value) {
        setState(() {
          _reportType = value!;
          _statusMessage = '';
        });
      },
    );
  }

  Widget _buildDailySelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Select Date',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat.yMMMMd().format(_selectedDate),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildMonthlySelector() {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Month',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              prefixIcon: const Icon(Icons.calendar_today),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedMonth,
                onChanged: (int? value) {
                  setState(() {
                    _selectedMonth = value!;
                    _statusMessage = '';
                  });
                },
                items: List.generate(12, (index) {
                  return DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text(
                        DateFormat('MMMM').format(DateTime(2022, index + 1))),
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 5,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Year',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              prefixIcon: const Icon(Icons.date_range),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedYear,
                onChanged: (int? value) {
                  setState(() {
                    _selectedYear = value!;
                    _statusMessage = '';
                  });
                },
                items: List.generate(5, (index) {
                  final year = DateTime.now().year - index;
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearlySelector() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Year',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: const Icon(Icons.date_range),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedYear,
          onChanged: (int? value) {
            setState(() {
              _selectedYear = value!;
              _statusMessage = '';
            });
          },
          items: List.generate(5, (index) {
            final year = DateTime.now().year - index;
            return DropdownMenuItem<int>(
              value: year,
              child: Text(year.toString()),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _statusMessage = '';
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
      _statusMessage = '';
    });

    try {
      final phoneProvider = Provider.of<PhoneProvider>(context, listen: false);
      await phoneProvider.loadPhones();

      late List<Phone> reportPhones;
      late DateTime startDate;
      late DateTime endDate;
      late String reportTitle;

      // Configure report based on type
      if (_reportType == 'daily') {
        startDate = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day);
        endDate = DateTime(_selectedDate.year, _selectedDate.month,
            _selectedDate.day, 23, 59, 59);
        reportTitle =
            'Daily Sales Report - ${DateFormat.yMMMMd().format(_selectedDate)}';

        // Get phones sold on selected date
        reportPhones = phoneProvider.soldPhones.where((phone) {
          return phone.saleDate != null &&
              (phone.saleDate!.isAtSameMomentAs(startDate) ||
                  (phone.saleDate!.isAfter(startDate) &&
                      phone.saleDate!.isBefore(endDate)) ||
                  phone.saleDate!.isAtSameMomentAs(endDate));
        }).toList();
      } else if (_reportType == 'monthly') {
        startDate = DateTime(_selectedYear, _selectedMonth, 1);
        endDate = DateTime(_selectedYear, _selectedMonth + 1, 0, 23, 59, 59);
        reportTitle =
            'Monthly Sales Report - ${DateFormat('MMMM yyyy').format(startDate)}';

        // Get phones sold in selected month
        reportPhones = phoneProvider.soldPhones.where((phone) {
          return phone.saleDate != null &&
              phone.saleDate!.year == _selectedYear &&
              phone.saleDate!.month == _selectedMonth;
        }).toList();
      } else {
        // yearly
        startDate = DateTime(_selectedYear, 1, 1);
        endDate = DateTime(_selectedYear, 12, 31, 23, 59, 59);
        reportTitle = 'Yearly Sales Report - $_selectedYear';

        // Get phones sold in selected year
        reportPhones = phoneProvider.soldPhones.where((phone) {
          return phone.saleDate != null &&
              phone.saleDate!.year == _selectedYear;
        }).toList();
      }

      if (reportPhones.isEmpty) {
        setState(() {
          _isGenerating = false;
          _statusMessage = 'No sales data found for selected period';
        });
        return;
      }

      final pdfFile = await PdfReportGenerator.generateSalesReport(
        phones: reportPhones,
        title: reportTitle,
        startDate: startDate,
        endDate: endDate,
      );

      // Show share options
      await _showShareOptions(pdfFile);

      setState(() {
        _isGenerating = false;
        _statusMessage = 'Report generated successfully!';
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _statusMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _showShareOptions(File pdfFile) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Generated'),
        content: const Text('What would you like to do with the report?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              PdfReportGenerator.openPdfFile(pdfFile);
            },
            child: const Text('Open'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              PdfReportGenerator.sharePdfFile(pdfFile);
            },
            child: const Text('Share'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
