import 'package:flutter/material.dart';
import 'invoices_screen.dart';
import 'customers_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // الشاشات التي سيتم التنقل بينها
  final List<Widget> _screens = [
    const InvoicesScreen(), // شاشة الفواتير
    const CustomersScreen(), // شاشة العملاء
    const SettingsScreen(), // شاشة الإعدادات
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'الفواتير',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'العملاء',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}