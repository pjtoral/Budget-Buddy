import 'package:firebase_core/firebase_core.dart';
import 'package:budgetbuddy_project/firebase_options.dart';
import 'package:budgetbuddy_project/screens/authorization_pages/login.dart';
import 'package:budgetbuddy_project/screens/home_page/home_page.dart';
import 'package:budgetbuddy_project/screens/transactions_page/transaction_page.dart';
import 'package:budgetbuddy_project/screens/analytics_page/analytics_page.dart';
import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupLocator();
  await LocalStorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late LocalStorageService storage;
  bool loggedIn = false;

  @override
  void initState() {
    storage = locator<LocalStorageService>();
    getUser();
    super.initState();
  }

  void getUser() async {
    bool isLogged = await storage.isLoggedIn();
    print(isLogged);
    setState(() {
      loggedIn = isLogged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Buddy',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:
          loggedIn
              ? HomePage(
                onSeeMoreTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionsPage(),
                    ),
                  );
                },
                onAnalyticsTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnalyticsPage(),
                    ),
                  );
                },
              )
              : const LoginScreen(),
    );
  }
}
