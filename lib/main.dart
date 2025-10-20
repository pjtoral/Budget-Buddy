import 'package:budgetbuddy_project/widgets/BottomNavBar.dart';
import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'screens/login.dart';

LocalStorageService storage = LocalStorageService();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await LocalStorageService.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LocalStorageService storage = locator<LocalStorageService>();
  bool loggedIn = false;

  @override
  void initState() {
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
      title: 'Simple Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: loggedIn ? HomeScreen() : LoginScreen(),
    );
  }
}
