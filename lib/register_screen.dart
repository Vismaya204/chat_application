import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_application/login_screen.dart';
import 'package:chat_application/service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _authService = AuthService();

  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();

  final picker = ImagePicker();
  File? image;
  Uint8List? webImage;
  bool loading = false;

  Future<void> picimage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          webImage = bytes;
          image = File(picked.path); // still needed for preview
        });
      } else {
        setState(() {
          image = File(picked.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          :
              
                 Container(height: double.infinity,width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                         Color.fromARGB(255, 163, 33, 243),
                        Colors.lightBlueAccent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                         SizedBox(height: 40),
                         Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                         SizedBox(height: 20),
                        GestureDetector(
                          onTap: picimage,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: kIsWeb
                                ? (webImage != null
                                      ? MemoryImage(webImage!)
                                      : null)
                                : (image != null ? FileImage(image!) : null)
                                      as ImageProvider?,
                            child: (image == null && webImage == null)
                                ? const Icon(Icons.camera_alt)
                                : null,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(controller: username,
                          decoration: InputDecoration(
                            hintText: "Username",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),filled: true,fillColor: Colors.white
                          ),
                         
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: email,
                          decoration: InputDecoration(
                            hintText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),filled: true,fillColor: Colors.white
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: password,
                          decoration: InputDecoration(
                            hintText: "Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),filled: true,fillColor: Colors.white
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(controller: phone,
                          decoration: InputDecoration(hintText: "Phone Number",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),filled: true,fillColor: Colors.white
                          ),
                        ),
                         SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            setState(() {
                              loading = true;
                            });
                    
                            XFile? xfileImage;
                            if (!kIsWeb && image != null) {
                              xfileImage = XFile(image!.path);
                            }
                    
                            final result = await _authService.register(
                              name: username.text.trim(),
                              email: email.text.trim(),
                              phone: phone.text.trim(),
                              password: password.text.trim(),
                              profileImage: xfileImage,
                              webImage: webImage,
                            );
                    
                            setState(() {
                              loading = false;
                            });
                    
                            if (result == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Registration successful"),
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Login(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $result")),
                              );
                            }
                          },
                          child: const Text("Register"),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                            );
                          },
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                  ),
                ),
              
            
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
