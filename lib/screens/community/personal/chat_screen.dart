import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/theme_provider.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  const ChatScreen({super.key, this.userName = "User"});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = []; // Dummy messages

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    
    // Background Image Logic
    final String bgImage = isDark 
        ? 'assets/images/tech_bg.png' 
        : 'assets/images/blossom_bg.jpg';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.userName),
        leading: const BackButton(),
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                bgImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Chat Content
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 16), // Top padding for AppBar
                  itemCount: _messages.length + 2, // +2 for dummy messages
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildMessage("Hello!", false);
                    if (index == 1) return _buildMessage("Hi there! How are you?", true);
                    return _buildMessage(_messages[index - 2], true);
                  },
                ),
              ),
              _buildInputArea(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe 
              ? Colors.blueAccent.withOpacity(0.8) 
              : Colors.grey.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: isDark ? Colors.black54 : Colors.white54,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: isDark ? Colors.white24 : Colors.white70,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.blue,
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                setState(() {
                  _messages.add(_messageController.text);
                  _messageController.clear();
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
