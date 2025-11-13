import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("📩 Messages à venir bientôt."),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
    );
  }
}
