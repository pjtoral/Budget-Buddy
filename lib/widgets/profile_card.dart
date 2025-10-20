import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileCard extends StatelessWidget {
  final String username;
  final String avatarAssetPath;

  const ProfileCard({
    super.key,
    required this.username,
    required this.avatarAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(screenWidth * 0.1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: screenWidth * 0.07,
            backgroundImage: AssetImage(avatarAssetPath),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, Welcome!',
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                Text(
                  username,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/logo.png',
            height: screenWidth * 0.08,
            width: screenWidth * 0.08,
          ),
        ],
      ),
    );
  }
}
