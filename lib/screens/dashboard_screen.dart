import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/stats_provider.dart';
import '../utils/formatters.dart';
import 'sales_report_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final statsProvider = Provider.of<StatsProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await statsProvider.loadAllCurrentStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard header with Sales Report button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SalesReportScreen()),
                      );
                    },
                    icon: const Icon(Icons.summarize, size: 20),
                    label: const Text('Sales Reports'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Inventory Stats Card
              _buildStatCard(
                title: 'Current Inventory',
                stats: [
                  StatItem(
                    title: 'Phones in Stock',
                    value:
                        statsProvider.inventoryStats['phonesCount'].toString(),
                    icon: Icons.phone_iphone,
                  ),
                  StatItem(
                    title: 'Total Investment',
                    value: Formatters.formatCurrency(
                        statsProvider.inventoryStats['totalCost']),
                    icon: Icons.account_balance_wallet,
                  ),
                ],
              ),

              // Daily Stats Card with Date Selector
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Daily Sales',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2020),
                                lastDate:
                                    DateTime.now().add(const Duration(days: 1)),
                              );
                              if (picked != null && picked != _selectedDate) {
                                setState(() {
                                  _selectedDate = picked;
                                });
                                await statsProvider
                                    .loadDailyStats(_selectedDate);
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  DateFormat('MMM dd, yyyy')
                                      .format(_selectedDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.calendar_today, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildStatsList([
                        StatItem(
                          title: 'Phones Sold',
                          value: statsProvider.dailyStats['phonesCount']
                              .toString(),
                          icon: Icons.sell,
                        ),
                        StatItem(
                          title: 'Revenue',
                          value: Formatters.formatCurrency(
                              statsProvider.dailyStats['totalRevenue']),
                          icon: Icons.attach_money,
                        ),
                        StatItem(
                          title: 'Profit',
                          value: Formatters.formatCurrency(
                              statsProvider.dailyStats['totalProfit']),
                          icon: Icons.trending_up,
                        ),
                      ]),
                    ],
                  ),
                ),
              ),

              // Monthly Stats Card with Month/Year Selector
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Monthly Sales',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () => _selectMonthYear(context),
                            child: Row(
                              children: [
                                Text(
                                  DateFormat('MMMM yyyy').format(
                                      DateTime(_selectedYear, _selectedMonth)),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.calendar_today, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildStatsList([
                        StatItem(
                          title: 'Phones Sold',
                          value: statsProvider.monthlyStats['phonesCount']
                              .toString(),
                          icon: Icons.sell,
                        ),
                        StatItem(
                          title: 'Revenue',
                          value: Formatters.formatCurrency(
                              statsProvider.monthlyStats['totalRevenue']),
                          icon: Icons.attach_money,
                        ),
                        StatItem(
                          title: 'Profit',
                          value: Formatters.formatCurrency(
                              statsProvider.monthlyStats['totalProfit']),
                          icon: Icons.trending_up,
                        ),
                      ]),
                    ],
                  ),
                ),
              ),

              // Yearly Stats Card with Year Selector
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Yearly Sales',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () => _selectYear(context),
                            child: Row(
                              children: [
                                Text(
                                  _selectedYear.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.calendar_today, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildStatsList([
                        StatItem(
                          title: 'Phones Sold',
                          value: statsProvider.yearlyStats['phonesCount']
                              .toString(),
                          icon: Icons.sell,
                        ),
                        StatItem(
                          title: 'Revenue',
                          value: Formatters.formatCurrency(
                              statsProvider.yearlyStats['totalRevenue']),
                          icon: Icons.attach_money,
                        ),
                        StatItem(
                          title: 'Profit',
                          value: Formatters.formatCurrency(
                              statsProvider.yearlyStats['totalProfit']),
                          icon: Icons.trending_up,
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    int selectedMonth = _selectedMonth;
    int selectedYear = _selectedYear;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Month and Year'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Month selection
                  DropdownButton<int>(
                    value: selectedMonth,
                    isExpanded: true,
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedMonth = newValue;
                        });
                      }
                    },
                    items: List.generate(
                      12,
                      (index) => DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(DateFormat('MMMM')
                            .format(DateTime(2022, index + 1))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Year selection
                  DropdownButton<int>(
                    value: selectedYear,
                    isExpanded: true,
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedYear = newValue;
                        });
                      }
                    },
                    items: List.generate(
                      10,
                      (index) => DropdownMenuItem<int>(
                        value: DateTime.now().year - 5 + index,
                        child:
                            Text((DateTime.now().year - 5 + index).toString()),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == true) {
        setState(() {
          _selectedMonth = selectedMonth;
          _selectedYear = selectedYear;
        });
        final statsProvider =
            Provider.of<StatsProvider>(context, listen: false);
        statsProvider.loadMonthlyStats(_selectedYear, _selectedMonth);
      }
    });
  }

  Future<void> _selectYear(BuildContext context) async {
    int selectedYear = _selectedYear;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<int>(
                value: selectedYear,
                isExpanded: true,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedYear = newValue;
                    });
                  }
                },
                items: List.generate(
                  10,
                  (index) => DropdownMenuItem<int>(
                    value: DateTime.now().year - 5 + index,
                    child: Text((DateTime.now().year - 5 + index).toString()),
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == true) {
        setState(() {
          _selectedYear = selectedYear;
        });
        final statsProvider =
            Provider.of<StatsProvider>(context, listen: false);
        statsProvider.loadYearlyStats(_selectedYear);
      }
    });
  }

  Widget _buildStatCard(
      {required String title, required List<StatItem> stats}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildStatsList(stats),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsList(List<StatItem> stats) {
    return Column(
      children: stats
          .map((stat) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(stat.icon, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      stat.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      stat.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class StatItem {
  final String title;
  final String value;
  final IconData icon;

  StatItem({required this.title, required this.value, required this.icon});
}
