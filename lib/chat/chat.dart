// chat.dart

// MARK: Imports
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// MARK: Chat Class
class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  // Chat Messages
  final List<ChatMessage> messages = [];

  // Text Field Controller
  TextEditingController controller = TextEditingController();

  // Build the app
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chef.ai'),
      ),
      body: Stack(
        children: [
          // Messages
          ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index == messages.length - 1 ? 75 : 0),
                child: message.isLoading ?
                // MARK: Loading Message
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ),
                  ),
                ) :
                // MARK: User Message
                message.you ?
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        message.content,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ) :
                // MARK: AI Message
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        message.content,
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // MARK: Message Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                
                    // MARK: Text Field
                    Container(
                      height: 100,
                      width: MediaQuery.of(context).size.width -100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          decoration: const InputDecoration(
                            hintText: 'Ask me anything...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          controller: controller,
                          onSubmitted: (value) async {
                            // Send the message
                            _sendMessage(value);
                          },
                        ),
                      ),
                    ),
                
                    // MARK: Send Button
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        color: Theme.of(context).colorScheme.onSurface,
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          // Send the message
                          _sendMessage(controller.text);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: Send Message
  void _sendMessage(String message) async {
    // If the message is empty, return
    if (message.isEmpty) return;
    // If last message is loading, return
    if (messages.isNotEmpty && messages.last.isLoading) return;
    // Update the UI
    setState(() {
      // Clear the text field
      controller.clear();
      // Dismiss the keyboard
      FocusScope.of(context).unfocus();
      // Add User Message
      messages.add(ChatMessage(content: message, you: true));
      // Add loading AI Response
      messages.add(ChatMessage(content: '...', isLoading: true, you: false));
    });
    // Update the UI
    messages.last.content = await _getResponse(message);
    setState(() {
      // Update the UI
      messages.last.isLoading = false;
      // Scroll to the bottom
      Scrollable.ensureVisible(context);
    });
  }

  // MARK: Gemini Request
  Future<String> _getResponse(String prompt) async {
    // Create the model
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: dotenv.env['OPENAI_API_KEY'] ?? '',
    );

    // Identity prompt
    String identityPrompt = 'You are Chef.ai, a virtual chef assistant. You are to assist users in cooking and baking, when given a prompt. You will answer in a witty, Gordon Ramsay-like manner. You may also be given their inventory and asked to suggest a recipe.';

    // Return Prompt
    // String returnPrompt = 'Return all responses as JSON objects. Here is the prompt:';

    // Generate the content
    try {
      final response = await model.generateContent([Content.text(identityPrompt), Content.text(prompt)]);
      // Remove any newlines
      return response.text?.replaceAll('\n', '') ?? '*Failed to get response*';
    } catch (e) {
      return '*Failed to get response*';
    }
  }
}

// MARK: AI Chat Struct
class ChatMessage {
  String content;
  bool isLoading;
  final bool you; // if true, the message is from the user, if false, the message is from the AI
  
  ChatMessage({required this.content, this.isLoading = false, required this.you});
}