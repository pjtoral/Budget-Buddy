import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Track which tile is expanded
  int? _expandedTileIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF7F7F7),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _expandableSettingsTile(
                  index: 2,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  isExpanded: _expandedTileIndex == 2,
                  onTap: () {
                    setState(() {
                      _expandedTileIndex = _expandedTileIndex == 2 ? null : 2;
                    });
                  },
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ListTile(
                        title: Text(
                          'Enable Push Notifications',
                          style: TextStyle(color: Colors.black87),
                        ),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                Divider(),
                _expandableSettingsTile(
                  index: 3,
                  icon: Icons.palette,
                  title: 'Appearance',
                  isExpanded: _expandedTileIndex == 3,
                  onTap: () {
                    setState(() {
                      _expandedTileIndex = _expandedTileIndex == 3 ? null : 3;
                    });
                  },
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ListTile(
                        title: Text(
                          'Theme Options',
                          style: TextStyle(color: Colors.black87),
                        ),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                Divider(),
                _expandableSettingsTile(
                  index: 4,
                  icon: Icons.info_outline,
                  title: 'About',
                  isExpanded: _expandedTileIndex == 4,
                  onTap: () {
                    setState(() {
                      _expandedTileIndex = _expandedTileIndex == 4 ? null : 4;
                    });
                  },
                  children: [
                    ListTile(
                      title: Text(
                        'Version 1.0.0',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _expandableSettingsTile({
    required int index,
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        shape: Border(),
        trailing: Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: Colors.black26,
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) => onTap(),
        tilePadding: EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: EdgeInsets.only(left: 32, right: 8, bottom: 8),
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        children: children,
      ),
    );
  }
}
