import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white, // Light background for better icon visibility
      elevation: 16, // Stronger shadow effect
      shadowColor: const Color(0xff0b036c).withOpacity(0.6), // Your FAB color as shadow
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              index: 0,
            ),
            _buildNavItem(
              icon: Icons.favorite_outline,
              activeIcon: Icons.favorite,
              index: 1,
            ),
            const SizedBox(width: 40), // Space for FAB
            _buildNavItem(
              icon: Icons.list_outlined,
              activeIcon: Icons.list,
              index: 2,
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required int index,
  }) {
    final bool isSelected = selectedIndex == index;
    return IconButton(
      icon: Icon(
        isSelected ? activeIcon : icon,
        color: isSelected ? _primaryColor : Colors.grey[600],
        size: 28,
      ),
      onPressed: () => onItemTapped(index),
    );
  }

  // Custom color palette
  static const Color _primaryColor = Colors.black; // Muted red (medical theme)
}