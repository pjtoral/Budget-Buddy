import 'package:flutter/material.dart';
import 'package:budgetbuddy_project/screens/home_page/home_page.dart';
import 'package:budgetbuddy_project/screens//analytics_page/analytics_page.dart';
import 'package:budgetbuddy_project/screens/transactions_page/transaction_page.dart';
import 'package:budgetbuddy_project/screens/profile_page/profile_page.dart';
import 'package:budgetbuddy_project/screens/home_page/topup.dart';
import 'package:budgetbuddy_project/screens/home_page/deduct.dart';

/// A stateful widget that serves as the main navigation container for the app.
///
/// The `HomeScreen` widget provides a bottom navigation bar with five tabs:
/// Home, Analytics, a central FAB placeholder, History (Transactions), and Profile.
/// It also includes a floating action button (FAB) that opens a modal bottom sheet
/// for adding or deducting money from the user's balance.
///
/// The widget manages navigation between different pages and handles callbacks
/// for refreshing data and navigating between sections.
class HomeScreen extends StatefulWidget {
  /// Creates a `HomeScreen` widget.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// The state for the `HomeScreen` widget.
class _HomeScreenState extends State<HomeScreen> {
  /// The index of the currently selected navigation item.
  ///
  /// Index 0: Home, 1: Analytics, 2: FAB placeholder, 3: History, 4: Profile.
  int _selectedIndex = 0;

  /// Returns the list of pages corresponding to each navigation item.
  ///
  /// The pages are defined dynamically to allow passing callbacks for
  /// navigation and refresh actions.
  List<Widget> _pages() {
    return [
      HomePage(
        onSeeMoreTap:
            () => _onItemTapped(3), // Redirect to Transactions (index 3)
        onAnalyticsTap: () => _onItemTapped(1), // Redirect to Analytics
        onRefresh: () => setState(() {}), // Refresh callback
      ),
      const AnalyticsPage(),
      Container(), // Placeholder for FAB (index 2)
      const TransactionsPage(), // History is now index 3
      const ProfilePage(), // Profile is now index 4
    ];
  }

  /// Handles navigation when a bottom navigation item is tapped.
  ///
  /// Updates the [_selectedIndex] to display the corresponding page.
  /// Index 2 (FAB placeholder) is skipped as it's not a navigable page.
  void _onItemTapped(int index) {
    // Skip index 2 (FAB placeholder)
    if (index == 2) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  /// Displays a modal bottom sheet with options to add or deduct money.
  ///
  /// The bottom sheet contains two options:
  /// - "Add Money": Navigates to the TopUpPage for adding funds.
  /// - "Deduct Money": Navigates to the DeductPage for recording expenses.
  ///
  /// After completing either action, the home screen is refreshed to reflect
  /// the updated balance.
  void _showAddDeductMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Use a local state for the bottom sheet to manage tap feedback.
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Color addColor = Colors.green[50]!;
            Color deductColor = Colors.red[50]!;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar for the bottom sheet.
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 20),
                  // "Add Money" option.
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: addColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: Colors.green),
                    ),
                    title: Text(
                      'Add Money',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('Add to your balance'),
                    onTap: () async {
                      setModalState(() {
                        addColor = Colors.grey[200]!; // Indicate press
                      });
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => TopUpPage(
                                onConfirm: (double amount) async {
                                  setState(() {}); // Refresh home screen
                                },
                              ),
                        ),
                      );
                      setState(() {}); // Refresh after returning
                    },
                  ),
                  SizedBox(height: 8),
                  // "Deduct Money" option.
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: deductColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.remove, color: Colors.red),
                    ),
                    title: Text(
                      'Deduct Money',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('Record an expense'),
                    onTap: () async {
                      setModalState(() {
                        deductColor = Colors.grey[200]!; // Indicate press
                      });
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DeductPage(
                                onConfirm: (double amount) async {
                                  setState(() {}); // Refresh home screen
                                },
                              ),
                        ),
                      );
                      setState(() {}); // Refresh after returning
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      // Display the currently selected page.
      body: _pages()[_selectedIndex],
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom Navigation Bar with five items.
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 8,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: SizedBox(width: 48), // Placeholder for FAB (index 2)
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'History', // This is now index 3
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile', // This is now index 4
              ),
            ],
          ),
          // Floating Action Button positioned at the center of the bottom bar.
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 32,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB((0.2 * 255).round(), 0, 0, 0),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _showAddDeductMenu,
                backgroundColor: Colors.black,
                elevation: 0,
                shape: CircleBorder(),
                child: Icon(Icons.payments, color: Colors.white, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
