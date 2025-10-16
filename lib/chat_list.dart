import 'package:chat_application/chat_screen.dart';
import 'package:chat_application/login_screen.dart';
import 'package:chat_application/profilepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 163, 33, 243),
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "Chats",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
       actions: [
  PopupMenuButton<String>(
    icon: const Icon(Icons.more_vert, color: Colors.white),
    onSelected: (value) {
      if (value == 'logout') {
        FirebaseAuth.instance.signOut();
        // Navigate to login screen or show confirmation
        Navigator.push(context, MaterialPageRoute(builder: (context) => Login() ,));
      } else if (value == 'profile') {
        // Navigate to profile screen
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  ProfileEditScreen(),));
      }
    },
    itemBuilder: (BuildContext context) => [
      const PopupMenuItem(
        value: 'profile',
        child: Text('Profile'),
      ),
      const PopupMenuItem(
        value: 'logout',
        child: Text('Logout'),
      ),
    ],
  ),
],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final currentUser = _auth.currentUser;
          final users = snapshot.data!.docs
              .where((doc) => doc['uid'] != currentUser?.uid)
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user['profileImage'] != ''
                      ? NetworkImage(user['profileImage'])
                      : null,
                  child: user['profileImage'] == ''
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(user['name']),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Chat(
                        receiverId: user['uid'],
                        receiverName: user['name'],
                        receiverImage: user['profileImage'],
                      ), // You can pass user info here
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
