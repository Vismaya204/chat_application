import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverImage;


  const Chat({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    
  });

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Replace with actual UID

  Map<String, dynamic>? replyTo;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 163, 33, 243),
      iconTheme: IconThemeData(color: Colors.white),
        title:  Text(widget.receiverName,style: TextStyle(color: Colors.white),),
        leading:  CircleAvatar(backgroundImage: widget.receiverImage != ''
        ? NetworkImage(widget.receiverImage)
        : null,
    child: widget.receiverImage == ''
        ? const Icon(Icons.person)
        : null,
),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['senderId'] == currentUser!.uid && data['receiverId'] ==widget.receiverId) ||
                         (data['senderId'] == widget.receiverId && data['receiverId'] == currentUser.uid);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == currentUser!.uid;

                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          replyTo = data;
                        });
                      },
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data['replyText'] != null && data['replyText'].toString().isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.blue[300] : Colors.grey[400],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    data['replyText'],
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: isMe ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                ),
                              Text(
                                data['text'],
                                style: TextStyle(color: isMe ? Colors.white : Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (replyTo != null)
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Replying to: ${replyTo!['text']}",
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        replyTo = null;
                      });
                    },
                  )
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final text = messageController.text.trim();
                      if (text.isEmpty) return;

                      await FirebaseFirestore.instance.collection('messages').add({
                        'text': text,
                        'senderId': currentUser!.uid,
                        'receiverId':widget.receiverId,
                        'timestamp': FieldValue.serverTimestamp(),
                        'replyText': replyTo?['text'] ?? '',
                      });

                      messageController.clear();
                      setState(() {
                        replyTo = null;
                      });
                    },
                    child: const Text("Send"),
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