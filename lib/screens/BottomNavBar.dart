import 'package:flutter/material.dart';
import 'package:budgetbuddy_project/screens/home_page/home_page.dart';
import 'package:budgetbuddy_project/screens//analytics_page/analytics_page.dart';
import 'package:budgetbuddy_project/screens/home_page/transaction_page.dart';
import 'package:budgetbuddy_project/screens/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Define the pages dynamically so you can pass callbacks
  List<Widget> _pages() {
    return [
      HomePage(
        onSeeMoreTap: () => _onItemTapped(2), // Redirect to Transactions
        onAnalyticsTap: () => _onItemTapped(1), // Redirect to Analytics
      ),
      const AnalyticsPage(),
      const TransactionsPage(),
      const ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: _pages()[_selectedIndex], // Use the dynamic list here
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
