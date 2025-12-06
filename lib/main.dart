import 'package:firebase_core/firebase_core.dart';
import 'package:budgetbuddy_project/firebase_options.dart';
import 'package:budgetbuddy_project/screens/authorization_pages/login.dart';
import 'package:budgetbuddy_project/widgets/navigation_bar.dart';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        useMaterial3: false,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        colorScheme: ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      home: loggedIn ? const HomeScreen() : const LoginScreen(),
      routes: {'/main': (context) => const HomeScreen()},
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
    );
  }
}
