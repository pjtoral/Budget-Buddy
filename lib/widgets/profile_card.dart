import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A stateless widget that displays a user profile card with an avatar and username.
///
/// The `ProfileCard` widget shows a greeting message, the user's avatar image,
/// username, and the app logo. It is typically displayed at the top of the home
/// page to provide a personalized welcome experience.
///
/// The card uses responsive sizing based on screen dimensions to ensure proper
/// display across different device sizes.
class ProfileCard extends StatelessWidget {
  /// The username to display on the profile card.
  final String username;

  /// The asset path to the user's avatar image.
  ///
  /// This should be a valid path to an image asset in the project's assets folder.
  final String avatarAssetPath;

  /// Creates a `ProfileCard` widget.
  ///
  /// The [username] and [avatarAssetPath] parameters are required and must not be null.
  const ProfileCard({
    super.key,
    required this.username,
    required this.avatarAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing.
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      // Add margin and padding for spacing.
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.015,
      ),
      // Style the card with a white background, border, and rounded corners.
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(screenWidth * 0.1),
      ),
      child: Row(
        children: [
          // Display the user's avatar as a circular image.
          CircleAvatar(
            radius: screenWidth * 0.07,
            backgroundImage: AssetImage(avatarAssetPath),
          ),
          SizedBox(width: screenWidth * 0.03),
          // Display the greeting and username.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting message.
                Text(
                  'Hi, Welcome!',
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                // Username display.
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
          // Display the app logo.
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
