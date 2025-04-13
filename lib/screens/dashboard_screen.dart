import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';
import '../utils/formatters.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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

              // Daily Stats Card
              _buildStatCard(
                title: 'Today\'s Sales',
                stats: [
                  StatItem(
                    title: 'Phones Sold',
                    value: statsProvider.dailyStats['phonesCount'].toString(),
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
                ],
              ),

              // Monthly Stats Card
              _buildStatCard(
                title: 'This Month',
                stats: [
                  StatItem(
                    title: 'Phones Sold',
                    value: statsProvider.monthlyStats['phonesCount'].toString(),
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
                ],
              ),

              // Yearly Stats Card
              _buildStatCard(
                title: 'This Year',
                stats: [
                  StatItem(
                    title: 'Phones Sold',
                    value: statsProvider.yearlyStats['phonesCount'].toString(),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
            ...stats
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
          ],
        ),
      ),
    );
  }
}

class StatItem {
  final String title;
  final String value;
  final IconData icon;

  StatItem({required this.title, required this.value, required this.icon});
}
