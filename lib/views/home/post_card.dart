import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool liked = false;
  bool disliked = false;
  bool? isTrue;

  @override
  void initState() {
    super.initState();
    isTrue = widget.post['isTrue'];
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
                radius: 22, backgroundImage: NetworkImage(p['avatar'])),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['user'],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(p['time'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(p['category'],
                  style: const TextStyle(fontSize: 12, color: Colors.indigo)),
            )
          ]),
          const SizedBox(height: 12),
          Text(p['title'],
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(p['content'], style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 12),
          if (isTrue == null)
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                icon: const Icon(Icons.check, size: 18),
                label: Text('poll_true'.tr()),
                onPressed: () => setState(() => isTrue = true),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                icon: const Icon(Icons.close, size: 18),
                label: Text('poll_false'.tr()),
                onPressed: () => setState(() => isTrue = false),
              ),
            ])
          else
            Center(
                child: Text(
                    isTrue!
                        ? '✔️ ${'poll_true'.tr()}'
                        : '❌ ${'poll_false'.tr()}',
                    style:
                        TextStyle(color: isTrue! ? Colors.green : Colors.red))),
          const SizedBox(height: 12),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _reaction(Icons.thumb_up, p['likes'].toString(), liked, () {
              setState(() {
                liked = !liked;
                if (liked)
                  p['likes']++;
                else
                  p['likes']--;
              });
            }),
            _reaction(Icons.thumb_down, p['dislikes'].toString(), disliked, () {
              setState(() {
                disliked = !disliked;
                if (disliked)
                  p['dislikes']++;
                else
                  p['dislikes']--;
              });
            }),
            _reaction(Icons.comment, p['comments'].toString(), false, () {
              /* open comments */
            }),
            IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          ])
        ]),
      ),
    );
  }

  Widget _reaction(
      IconData icon, String count, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(children: [
        Icon(icon, color: active ? Colors.blue : Colors.grey),
        const SizedBox(width: 6),
        Text(count)
      ]),
    );
  }
}
