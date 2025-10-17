import 'package:chat_application/chatbot_service.dart';
import 'package:flutter/material.dart';

class Chatbot extends StatefulWidget {
   Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final List<Map<String, String>> Messagelist = [];
TextEditingController  box=TextEditingController();
bool isLoading = false;
Future <void> Sendmessage(String usermassage)async{setState(() {
  Messagelist.add({"role":"user","text":usermassage});
  isLoading=true;
});
final botreply=await Chatbotapi(box.text);
setState(() {
  Messagelist.add({"role":"bot","text":botreply!});
  isLoading=false;
  box.clear();
});
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(title: Center(child: Text("Chatbot",
      style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),)),leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(child: ClipOval(
          child: Image.network(
           "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ2AgcN8FoxPQZEINM3rZGkoSKphfltDN3qvA&s",
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),),
      ),
      actions: [Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(Icons.settings,color: Colors.white,),
      ),],backgroundColor: const Color.fromARGB(255, 163, 33, 243),),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: Messagelist.length,
                itemBuilder: (context, index) {
                  return messagebox(Messagelist.toList()[index]);
                },
              ),
            ),if (isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
            Row(
              children: [
                Expanded(
                  child: TextField(controller: box,
                  style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(hintText: "ask anything...",hintStyle:TextStyle(color: Colors.white), 
                      border: OutlineInputBorder(borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),filled: true,
                      fillColor: const Color.fromARGB(255, 163, 33, 243),
                    ),
                  ),
                ),SizedBox(width: 10,),
                IconButton(onPressed: () { if (box.text.trim().isNotEmpty) {
      Sendmessage(box.text.trim());
    }}, icon: Icon(Icons.send),color: const Color.fromARGB(255, 163, 33, 243),)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget messagebox(Map<String, String> message) {
    bool isuser = message["role"] == "user";
    return Align(alignment: isuser?Alignment.centerRight:Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isuser ? const Color.fromARGB(255, 163, 33, 243): Colors.white,
        ),
        child: Text(
          message['text'] ?? "",
          style: TextStyle(color: isuser ? Colors.white :  const Color.fromARGB(255, 163, 33, 243),),
        ),
      ),
    );
  }
}
