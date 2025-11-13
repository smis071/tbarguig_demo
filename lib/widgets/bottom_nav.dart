import 'package:flutter/material.dart';
import '../pages/map_page.dart';
import '../pages/home_page.dart';
import '../pages/messages_page.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0)
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const MapPage()));
        if (index == 1)
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomePage()));
        if (index == 2)
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const MessagesPage()));
      },
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), label: ''),
      ],
    );
  }
}
