import 'package:flutter/material.dart';
import '../../controller/logout_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Image.asset(
              'assets/images/HeartCare_logo.png',
              height: 40,
            ),
          ),
          IconButton(
            padding: const EdgeInsets.only(right: 20),
            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 28),
            onPressed: () {
              LogoutService.showLogoutConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
