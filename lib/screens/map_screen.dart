import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
            "🗺️ La carte sera affichée ici (intégration Google Maps bientôt)."),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}
