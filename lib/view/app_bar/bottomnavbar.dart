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
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: selectedIndex == 0 ? Colors.black : Colors.grey,
              ),
              onPressed: () => onItemTapped(0),
            ),
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: selectedIndex == 1 ? Colors.black : Colors.grey,
              ),
              onPressed: () => onItemTapped(1),
            ),
            const SizedBox(width: 40), // Space for FAB
            IconButton(
              icon: Icon(
                Icons.list,
                color: selectedIndex == 2 ? Colors.black : Colors.grey,
              ),
              onPressed: () => onItemTapped(2),
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: selectedIndex == 3 ? Colors.black : Colors.grey,
              ),
              onPressed: () => onItemTapped(3),
            ),
          ],
        ),
      ),
    );
  }
}
