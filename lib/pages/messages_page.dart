import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  // Créer une conversation de démonstration
  Future<void> _createDemoConversation() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Créer un utilisateur de démonstration
    final demoUser = {
      'displayName': 'Ahmed',
      'email': 'ahmed@demo.com',
      'photoURL': '',
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    };

    // Ajouter l'utilisateur de démonstration
    await _firestore.collection('users').doc('demo_user_id').set(demoUser);

    // Créer une conversation de démonstration
    final conversationData = {
      'participants': [currentUser.uid, 'demo_user_id'],
      'participantNames': {
        currentUser.uid: currentUser.displayName ??
            currentUser.email?.split('@').first ??
            'Vous',
        'demo_user_id': 'Ahmed',
      },
      'participantEmails': {
        currentUser.uid: currentUser.email,
        'demo_user_id': 'ahmed@demo.com',
      },
      'lastMessage': 'Salut ! Bienvenue sur Tberguig 👋',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSender': 'demo_user_id',
      'unreadCount': 1,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('conversations')
        .doc('demo_conversation')
        .set(conversationData);

    // Ajouter des messages de démonstration
    final messages = [
      {
        'senderId': 'demo_user_id',
        'senderName': 'Ahmed',
        'text': 'Salut ! Bienvenue sur Tberguig 👋',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
      },
      {
        'senderId': 'demo_user_id',
        'senderName': 'Ahmed',
        'text': 'Je suis là pour répondre à tes questions sur l\'application',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
      },
      {
        'senderId': _auth.currentUser?.uid,
        'senderName': _auth.currentUser?.displayName ?? 'Vous',
        'text': 'Merci ! L\'application est super 🎉',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
      },
    ];

    for (final message in messages) {
      await _firestore
          .collection('conversations')
          .doc('demo_conversation')
          .collection('messages')
          .add(message);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conversation de démonstration créée!')),
    );
    setState(() {});
  }

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
                    "Messages",
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

            // Barre de recherche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Rechercher une conversation...",
                    hintStyle: GoogleFonts.poppins(fontSize: 14),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),

            // Bouton pour créer une démo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _createDemoConversation,
                  icon: const FaIcon(FontAwesomeIcons.comment, size: 16),
                  label: Text(
                    "Créer une conversation de démonstration",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Liste des conversations
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('conversations')
                    .where('participants',
                        arrayContains: _auth.currentUser?.uid)
                    .orderBy('lastMessageTime', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final conversations = snapshot.data?.docs ?? [];

                  if (conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.comments,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune conversation',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Commencez une nouvelle conversation',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: _createDemoConversation,
                            child: Text(
                              "Créer une démo",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final data = conversation.data() as Map<String, dynamic>;

                      final participants =
                          List<String>.from(data['participants'] ?? []);
                      final otherUserId = participants.firstWhere(
                        (id) => id != _auth.currentUser?.uid,
                        orElse: () => '',
                      );

                      final participantNames = Map<String, String>.from(
                          data['participantNames'] ?? {});
                      final otherUserName =
                          participantNames[otherUserId] ?? 'Utilisateur';

                      final lastMessage =
                          data['lastMessage'] ?? 'Aucun message';
                      final lastMessageTime = data['lastMessageTime'] != null
                          ? DateFormat('HH:mm').format(
                              (data['lastMessageTime'] as Timestamp).toDate())
                          : '';

                      final unreadCount = data['unreadCount'] ?? 0;

                      return StreamBuilder<DocumentSnapshot>(
                        stream: _firestore
                            .collection('users')
                            .doc(otherUserId)
                            .snapshots(),
                        builder: (context, userSnapshot) {
                          final userData = userSnapshot.data?.data()
                              as Map<String, dynamic>?;
                          final isOnline = userData?['isOnline'] == true;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: userData?['photoURL'] !=
                                            null
                                        ? NetworkImage(userData!['photoURL'])
                                        : null,
                                    child: userData?['photoURL'] == null
                                        ? const FaIcon(
                                            FontAwesomeIcons.user,
                                            color: Colors.black54,
                                            size: 18,
                                          )
                                        : null,
                                  ),
                                  if (isOnline)
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
                              title: Text(
                                otherUserName,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Text(
                                lastMessage,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    lastMessageTime,
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (unreadCount > 0)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        unreadCount.toString(),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                _openChat(context, conversation.id,
                                    otherUserName, otherUserId);
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(BuildContext context, String conversationId, String userName,
      String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationId: conversationId,
          userName: userName,
          userId: userId,
        ),
      ),
    );
  }
}

// Écran de chat détaillé
class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String userName;
  final String userId;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.userName,
    required this.userId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = {
      'senderId': _auth.currentUser?.uid,
      'senderName': _auth.currentUser?.displayName ??
          _auth.currentUser?.email?.split('@').first ??
          'Vous',
      'text': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    };

    try {
      // Ajouter le message
      await _firestore
          .collection('conversations')
          .doc(widget.conversationId)
          .collection('messages')
          .add(message);

      // Mettre à jour la conversation
      await _firestore
          .collection('conversations')
          .doc(widget.conversationId)
          .update({
        'lastMessage': _messageController.text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': _auth.currentUser?.uid,
        'unreadCount': FieldValue.increment(1),
      });

      _messageController.clear();
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[200],
              child: const FaIcon(FontAwesomeIcons.user, size: 14),
            ),
            const SizedBox(width: 8),
            Text(
              widget.userName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('conversations')
                  .doc(widget.conversationId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final data = message.data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == _auth.currentUser?.uid;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isMe)
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[200],
                              child:
                                  const FaIcon(FontAwesomeIcons.user, size: 12),
                            ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.blue.shade50
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isMe)
                                    Text(
                                      data['senderName'] ?? 'Utilisateur',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  Text(
                                    data['text'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Écrivez un message...",
                        hintStyle: GoogleFonts.poppins(fontSize: 14),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black,
                  child: IconButton(
                    icon: const FaIcon(FontAwesomeIcons.paperPlane,
                        size: 14, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
