import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _categories = [
    {'title': 'Tous', 'emoji': '🌐'},
    {'title': 'Actualités nationales', 'emoji': '🇲🇦'},
    {'title': 'International', 'emoji': '🌍'},
    {'title': 'Économie & Business', 'emoji': '💼'},
    {'title': 'Sport', 'emoji': '⚽'},
    {'title': 'Culture & Lifestyle', 'emoji': '🎭'},
    {'title': 'Tech & Innovation', 'emoji': '💻'},
    {'title': 'Buzz & Réseaux sociaux', 'emoji': '🔥'},
    {'title': 'Religion & Société', 'emoji': '🕌'},
    {'title': 'Faits divers', 'emoji': '🚨'},
    {'title': 'Opinions / Podcasts', 'emoji': '🎙️'},
    {'title': 'Tberguig TV / Vidéos', 'emoji': '📺'},
  ];

  int _selectedCategoryIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _likeNews(
      String newsId, Map<String, dynamic> newsData, bool isLike) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final likedBy = List<String>.from(newsData['likedBy'] ?? []);
    final dislikedBy = List<String>.from(newsData['dislikedBy'] ?? []);

    if (isLike) {
      if (likedBy.contains(userId)) {
        await FirebaseFirestore.instance.collection('news').doc(newsId).update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        await FirebaseFirestore.instance.collection('news').doc(newsId).update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
          'dislikes': dislikedBy.contains(userId)
              ? FieldValue.increment(-1)
              : FieldValue.increment(0),
          'dislikedBy': FieldValue.arrayRemove([userId]),
        });
      }
    } else {
      if (dislikedBy.contains(userId)) {
        await FirebaseFirestore.instance.collection('news').doc(newsId).update({
          'dislikes': FieldValue.increment(-1),
          'dislikedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        await FirebaseFirestore.instance.collection('news').doc(newsId).update({
          'dislikes': FieldValue.increment(1),
          'dislikedBy': FieldValue.arrayUnion([userId]),
          'likes': likedBy.contains(userId)
              ? FieldValue.increment(-1)
              : FieldValue.increment(0),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      }
    }
  }

  void _addComment(String newsId) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Ajouter un commentaire'),
            content: TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Écrivez votre commentaire...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  if (commentController.text.isNotEmpty) {
                    final user = _auth.currentUser;
                    try {
                      // إضافة التعليق
                      await FirebaseFirestore.instance
                          .collection('comments')
                          .add({
                        'newsId': newsId,
                        'userId': user?.uid,
                        'userEmail': user?.email,
                        'comment': commentController.text,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      // تحديث عدد التعليقات في الخبر
                      await FirebaseFirestore.instance
                          .collection('news')
                          .doc(newsId)
                          .update({
                        'comments': FieldValue.increment(1),
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Commentaire ajouté avec succès!')),
                      );

                      setState(() {});
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Veuillez écrire un commentaire')),
                    );
                  }
                },
                child: const Text('Ajouter'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tberguig",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.plus,
                            color: Colors.black, size: 20),
                        onPressed: () {
                          Navigator.pushNamed(context, '/addNews');
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[200],
                          child: const FaIcon(FontAwesomeIcons.user,
                              color: Colors.black87, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Catégories - مضمون التمرير
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategoryIndex == index;

                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(category['emoji'],
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          category['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Liste des news
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('news')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  final news = snapshot.data?.docs ?? [];

                  if (news.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.newspaper,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun Tberguig pour le moment',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Soyez le premier à partager!',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: news.length,
                      itemBuilder: (context, index) {
                        final newsItem = news[index];
                        final data = newsItem.data() as Map<String, dynamic>;
                        final userId = user?.uid;
                        final likedBy =
                            List<String>.from(data['likedBy'] ?? []);
                        final dislikedBy =
                            List<String>.from(data['dislikedBy'] ?? []);

                        final isLiked =
                            userId != null && likedBy.contains(userId);
                        final isDisliked =
                            userId != null && dislikedBy.contains(userId);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // En-tête
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey[200],
                                    child: data['userAvatar'] != null &&
                                            data['userAvatar'].isNotEmpty
                                        ? CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                data['userAvatar']),
                                            radius: 14,
                                          )
                                        : const FaIcon(FontAwesomeIcons.user,
                                            size: 14, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    data['userEmail']?.split('@').first ??
                                        'Utilisateur',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    data['emoji'] ?? '📰',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    data['category'] ?? 'Général',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Titre
                              Text(
                                data['title'] ?? '',
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Actions
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: FaIcon(
                                          FontAwesomeIcons.solidThumbsUp,
                                          size: 18,
                                          color: isLiked
                                              ? Colors.green.shade600
                                              : Colors.grey.shade600,
                                        ),
                                        onPressed: userId == null
                                            ? null
                                            : () => _likeNews(
                                                newsItem.id, data, true),
                                      ),
                                      Text(
                                        "${data['likes'] ?? 0}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isLiked
                                              ? Colors.green.shade600
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: FaIcon(
                                          FontAwesomeIcons.solidThumbsDown,
                                          size: 18,
                                          color: isDisliked
                                              ? Colors.red.shade600
                                              : Colors.grey.shade600,
                                        ),
                                        onPressed: userId == null
                                            ? null
                                            : () => _likeNews(
                                                newsItem.id, data, false),
                                      ),
                                      Text(
                                        "${data['dislikes'] ?? 0}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isDisliked
                                              ? Colors.red.shade600
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const FaIcon(
                                          FontAwesomeIcons.commentDots,
                                          size: 18,
                                          color: Colors.blueGrey,
                                        ),
                                        onPressed: () =>
                                            _addComment(newsItem.id),
                                      ),
                                      Text(
                                        "${data['comments'] ?? 0}",
                                        style:
                                            GoogleFonts.poppins(fontSize: 13),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const FaIcon(
                                          FontAwesomeIcons.shareNodes,
                                          size: 18,
                                          color: Colors.blueAccent,
                                        ),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "Fonction de partage à venir...")),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
