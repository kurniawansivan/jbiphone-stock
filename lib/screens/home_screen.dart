import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/phone_provider.dart';
import '../providers/stats_provider.dart';
import 'dashboard_screen.dart';
import 'inventory_screen.dart';
import 'add_phone_screen.dart';
import 'sold_phones_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const InventoryScreen(),
    const SoldPhonesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load phone data from the database when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PhoneProvider>(context, listen: false).loadPhones();
      Provider.of<StatsProvider>(context, listen: false).loadAllCurrentStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JBIphone Stock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Reload data when refresh button is pressed
              Provider.of<PhoneProvider>(context, listen: false).loadPhones();
              Provider.of<StatsProvider>(context, listen: false)
                  .loadAllCurrentStats();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data refreshed')),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPhoneScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_iphone),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Sold',
          ),
        ],
      ),
    );
  }
}
