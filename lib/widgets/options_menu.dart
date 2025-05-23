// options_menu.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../session_manager.dart';


class OptionsMenu extends StatelessWidget {
  const OptionsMenu({super.key});

  void _handleMenuSelection(String value) async {
    switch (value) {
      case 'home':
        Get.offAllNamed('/dashboard');
        break;
      case 'refresh':
        Get.forceAppUpdate(); // Optional: implement screen refresh
        break;
      case 'logout':
        await SessionManager.clearSession();
        Get.offAllNamed('/login');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: _handleMenuSelection,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'home',
          child: Row(
            children: const [
              Icon(Icons.home, color: Colors.black54),
              SizedBox(width: 10),
              Text('Home'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'refresh',
          child: Row(
            children: const [
              Icon(Icons.refresh, color: Colors.black54),
              SizedBox(width: 10),
              Text('Refresh'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, color: Colors.black54),
              SizedBox(width: 10),
              Text('Logout'),
            ],
          ),
        ),
      ],
    );
  }
}
