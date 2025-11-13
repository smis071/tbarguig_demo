import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String username;
  final String timeAgo;
  final String content;
  final String imageUrl;
  final int likes;
  final int comments;

  const PostCard({
    Key? key,
    required this.username,
    required this.timeAgo,
    required this.content,
    required this.imageUrl,
    required this.likes,
    required this.comments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: user info + time
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(timeAgo,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Post content
            Text(content, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 10),

            // Post image (if exists)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                errorBuilder: (context, error, stackTrace) =>
                    const Text('❌ Failed to load image'),
              ),
            ),

            const SizedBox(height: 10),

            // Likes & comments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.thumb_up_alt_outlined, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('$likes Likes'),
                ]),
                Row(children: [
                  const Icon(Icons.comment_outlined, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('$comments Comments'),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
