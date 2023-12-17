import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat with ChatGPT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final apiKey = 'xxxxxxxxxxxxxxxxxxxxxxx'; // Replace with your OpenAI API key
  final apiUrl = 'https://api.openai.com/v1/chat/completions';

  List<Map<String, String>> conversation = [];
  TextEditingController userInputController = TextEditingController();
  List<String> chatHistory = [];

  Future<void> sendMessage() async {
    String userInput = userInputController.text;

    if (userInput == 'ex') {
      // Handle exit here if needed
      return;
    }

    // Add the user input to the conversation history
    conversation.add({'role': 'user', 'content': userInput});

    // Send the entire conversation history to OpenAI API
    final response = await _sendMessage(apiUrl, apiKey, conversation);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final message = responseData['choices'][0]['message']['content'];

      // Add the model response to the conversation history
      conversation.add({'role': 'assistant', 'content': message});

      // Update chat history for displaying in UI
      chatHistory.add('User: $userInput');
      chatHistory.add('AI: $message');
    } else {
      final errorData = jsonDecode(response.body);
      chatHistory.add('Error: ${errorData['error']['message']}');
    }

    userInputController.clear();
    setState(() {});
  }

  Future<http.Response> _sendMessage(String apiUrl, String apiKey, List<Map<String, String>> conversation) async {
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final data = {
      'model': 'gpt-3.5-turbo', // Specify the GPT-3 "chat" model
      'messages': conversation,
      'max_tokens': 50, // Adjust as needed
      'temperature': 0.7, // Adjust as needed
      'stop': '\n', // Stop at the end of the response
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(data),
    );

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ChatGPT'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(chatHistory[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: userInputController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: sendMessage,
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
