import 'package:chat_application/chat_list.dart';
import 'package:chat_application/service.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email=TextEditingController();
  TextEditingController password=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 163, 33, 243),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [Text("Login",style: TextStyle(fontSize: 30,color: Colors.white,fontWeight: FontWeight.bold),),
            SizedBox(height: 50,),
            TextFormField(controller: email,
              decoration: InputDecoration(
                hintText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),filled: true,fillColor: Colors.white
              ),
            ),
            SizedBox(height: 10),
            TextFormField(controller: password,
              decoration: InputDecoration(
                hintText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),filled: true,fillColor: Colors.white
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
              AuthService.loginUser(email.text, password.text,context);
                },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
