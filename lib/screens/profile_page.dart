import 'package:budgetbuddy_project/screens/profile_page/about.dart';
import 'package:budgetbuddy_project/screens/profile_page/helpsupport.dart';
import 'package:budgetbuddy_project/screens/profile_page/notification.dart';
import 'package:budgetbuddy_project/screens/profile_page/settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Widget _buildProfileOption(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'John Doe',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'john.doe@example.com',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            _buildProfileOption(
              Icons.settings,
              'Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            _buildProfileOption(
              Icons.notifications,
              'Notifications',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
            ),
            _buildProfileOption(
              Icons.help,
              'Help & Support',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpSupportPage()),
                );
              },
            ),
            _buildProfileOption(
              Icons.info,
              'About',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Logout', style: GoogleFonts.inter(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
