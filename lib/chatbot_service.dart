import 'dart:convert';
import "package:http/http.dart" as http;

Future<String?> Chatbotapi(String usermassage) async {
  final url = Uri.parse(
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyAxBdeZXEZHUHBSI6B3znqSsrR4LqOgbvQ",
  );
  final headers = {"Content-Type": "application/json"};
  final body = jsonEncode({
    "contents": [
      {
        "parts": [
          {"text": usermassage},
        ],
      },
    ],
  });
  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
     return data["candidates"][0]["content"]['parts'][0]['text'];
    } else {
      return "Something is wrong";
    }
  } catch (e) {
    print("$e");
  }
}
