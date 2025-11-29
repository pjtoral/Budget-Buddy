import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budgetbuddy_project/services/auth_service.dart';
import 'package:budgetbuddy_project/services/category_service.dart';
import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
import 'package:budgetbuddy_project/widgets/navigation_bar.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final user = await AuthService().signUpWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
        displayName: usernameController.text.trim(),
        username: usernameController.text.trim(),
      );

      // Optional: hydrate categories cache after sign-up
      await locator<CategoryService>().syncCategoriesToLocal();

      if (!mounted) return;
      if (user != null) {
        // Set logged-in state
        final storage = locator<LocalStorageService>();
        await storage.setLoggedIn(true);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter your email';
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim()))
          return 'Enter a valid email';
        return null;
      },
    );

    final usernameField = TextFormField(
      controller: usernameController,
      decoration: InputDecoration(
        labelText: 'Username',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.person_outline),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter a username';
        if (v.trim().length < 3)
          return 'Username must be at least 3 characters';
        return null;
      },
    );

    final passwordField = TextFormField(
      controller: passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.lock_outline),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please enter a password';
        if (v.length < 8) return 'Password must be at least 8 characters';
        return null;
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Budget Buddy',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Image.asset('assets/images/logo.png', height: 40, width: 40),
                  const SizedBox(height: 40),
                  Text(
                    'Create your account',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  emailField,
                  const SizedBox(height: 16),
                  usernameField,
                  const SizedBox(height: 16),
                  passwordField,
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.black.withOpacity(0.6),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                'Sign Up',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: GoogleFonts.inter(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Log in',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
