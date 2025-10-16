import 'dart:convert';
import 'package:chat_application/chat_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Replace these with your actual Cloudinary credentials
  final String cloudName = 'dc0ny45w9'; // e.g. "myapp123"
  final String uploadPreset = 'profileimg'; // e.g. "unsigned_upload"

  Future<String?> uploadProfileImage(
    XFile? profileImage,
    Uint8List? webImage,
  ) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      var request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;

      if (kIsWeb && webImage != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            webImage,
            filename: 'profile.png',
          ),
        );
      } else if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', profileImage.path),
        );
      } else {
        return null;
      }

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        var data = json.decode(responseData.body);
        print("✅ Cloudinary upload success: ${data['secure_url']}");
        return data['secure_url'];
      } else {
        print("❌ Cloudinary upload failed: ${response.statusCode}");
        print("Response: ${responseData.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error uploading to Cloudinary: $e");
      return null;
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    XFile? profileImage,
    Uint8List? webImage,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // ✅ Upload image (if selected)
      String? imageUrl;
      if (profileImage != null || webImage != null) {
        imageUrl = await uploadProfileImage(profileImage, webImage);
      }

      // ✅ Save user info to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': name,
            'email': email,
            'phone': phone,
            'profileImage': imageUrl ?? '',
            'uid': userCredential.user!.uid,
            'role': 'user',
          });

      print("✅ User registered successfully");
      return null;
    } catch (e) {
      print("❌ Signup error: $e");
      return e.toString();
    }
  }

  static Future<void> loginUser(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatList()),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login successful")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("An unexpected error occurred.")));
    }
  }
}
