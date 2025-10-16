import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:chat_application/service.dart'; // Your image upload logic

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final emailController = TextEditingController();
  final picker = ImagePicker();
  final authService = AuthService();

  File? updatedImage;
  Uint8List? updatedWebImage;
  String? imageUrlFromFirestore;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        emailController.text = data['email'] ?? '';
        imageUrlFromFirestore = data['profileImage'] ?? '';
        setState(() {}); // Trigger UI update
      }
    }
  }
}

  Future<void> pickNewImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          updatedWebImage = bytes;
          updatedImage = null;
        });
      } else {
        setState(() {
          updatedImage = File(picked.path);
          updatedWebImage = null;
        });
      }
    }
  }

  Future<void> saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final email = emailController.text.trim();

    final imageUrl = await authService.uploadProfileImage(
      updatedImage != null ? XFile(updatedImage!.path) : null,
      updatedWebImage,
    );

    if (uid != null && imageUrl != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'email': email,
        'profileImage': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile updated")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to update profile")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallbackImage = (updatedImage == null &&
        updatedWebImage == null &&
        (imageUrlFromFirestore == null || imageUrlFromFirestore!.isEmpty));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color.fromARGB(255, 163, 33, 243),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
           GestureDetector(
  onTap: pickNewImage,
  child: CircleAvatar(
    radius: 60,
    backgroundImage: updatedWebImage != null
        ? MemoryImage(updatedWebImage!)
        : updatedImage != null
            ? FileImage(updatedImage!)
            : imageUrlFromFirestore != null && imageUrlFromFirestore!.isNotEmpty
                ? NetworkImage(imageUrlFromFirestore!)
                : null,
    child: fallbackImage
        ? const Icon(Icons.person, size: 40)
        : null,
  ),
),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}