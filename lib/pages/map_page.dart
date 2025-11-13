import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header personnalisé
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "Carte",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.plus, size: 20),
                    onPressed: () {
                      Navigator.pushNamed(context, '/addNews');
                    },
                  ),
                ],
              ),
            ),

            // Carte interactive avec utilisateurs
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data?.docs ?? [];
                  final onlineUsers = users.where((user) {
                    final data = user.data() as Map<String, dynamic>;
                    return data['isOnline'] == true;
                  }).toList();

                  return Stack(
                    children: [
                      // Carte du Maroc stylisée
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.blue.shade50,
                              Colors.green.shade50,
                            ],
                          ),
                        ),
                        child: CustomPaint(
                          painter: MoroccoMapPainter(users: onlineUsers),
                        ),
                      ),

                      // Légende et informations
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Utilisateurs en ligne",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${onlineUsers.length} personnes connectées au Maroc",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Liste des utilisateurs en bas
                      if (onlineUsers.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, -4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Handle pour glisser
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Connectés maintenant",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          "${onlineUsers.length}",
                                          style: GoogleFonts.poppins(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    itemCount: onlineUsers.length,
                                    itemBuilder: (context, index) {
                                      final user = onlineUsers[index];
                                      final data =
                                          user.data() as Map<String, dynamic>;
                                      final isCurrentUser =
                                          user.id == _auth.currentUser?.uid;

                                      return Container(
                                        width: 120,
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isCurrentUser
                                              ? Colors.blue.shade50
                                              : Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isCurrentUser
                                                ? Colors.blue.shade200
                                                : Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Stack(
                                              children: [
                                                CircleAvatar(
                                                  radius: 24,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  backgroundImage:
                                                      data['photoURL'] != null
                                                          ? NetworkImage(
                                                              data['photoURL'])
                                                          : null,
                                                  child: data['photoURL'] ==
                                                          null
                                                      ? const FaIcon(
                                                          FontAwesomeIcons.user,
                                                          color: Colors.black54,
                                                          size: 18,
                                                        )
                                                      : null,
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              data['displayName']
                                                      ?.split(' ')
                                                      .first ??
                                                  data['email']
                                                      ?.split('@')
                                                      .first ??
                                                  'Utilisateur',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              isCurrentUser
                                                  ? 'Vous'
                                                  : 'En ligne',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.green.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Peintre personnalisé pour la carte du Maroc
class MoroccoMapPainter extends CustomPainter {
  final List<QueryDocumentSnapshot> users;

  MoroccoMapPainter({required this.users});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade100
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Dessiner la forme simplifiée du Maroc
    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.2)
      ..lineTo(size.width * 0.7, size.height * 0.15)
      ..lineTo(size.width * 0.8, size.height * 0.4)
      ..lineTo(size.width * 0.6, size.height * 0.8)
      ..lineTo(size.width * 0.25, size.height * 0.7)
      ..lineTo(size.width * 0.2, size.height * 0.5)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    // Dessiner les points des utilisateurs
    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      final data = user.data() as Map<String, dynamic>;

      // Position aléatoire dans les limites du Maroc
      final random = (i + 1) / users.length;
      final x = size.width * (0.3 + random * 0.5);
      final y = size.height * (0.2 + random * 0.6);

      final userPaint = Paint()
        ..color = data['isOnline'] == true ? Colors.green : Colors.grey
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 8, userPaint);

      // Point blanc au centre
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
