import 'package:flutter/material.dart';

class NewsCard extends StatefulWidget {
  final String category;
  final String title;
  final String content;

  const NewsCard(
      {super.key,
      required this.category,
      required this.title,
      required this.content});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool? isTrue;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.category,
                style: const TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(widget.content),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.thumb_up_alt_outlined),
                const Icon(Icons.comment_outlined),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.check_circle,
                          color: isTrue == true ? Colors.green : Colors.grey),
                      onPressed: () => setState(() => isTrue = true),
                    ),
                    IconButton(
                      icon: Icon(Icons.cancel,
                          color: isTrue == false ? Colors.red : Colors.grey),
                      onPressed: () => setState(() => isTrue = false),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
