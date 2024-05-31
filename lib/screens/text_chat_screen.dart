import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/chatUIcomponents/assistant_message_card.dart';
import '../components/chatUIcomponents/user_message_card.dart';
import '../models/chatbot_provider.dart';
import '../models/chatbot_manager.dart';
import '../services/providers/chat_messages_provider/chat_messages_provider.dart';
import 'conversation_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final ChatbotManager manager = ChatbotManager();
  List<ChatbotProvider> providers = [
    ChatbotProvider(
        name: "OpenAI",
        sendMessage: (msg) async {
          // Placeholder for OpenAI API call logic
          return "Response from OpenAI";
        }),
  ];
  late ChatbotProvider selectedProvider;

  @override
  void initState() {
    super.initState();

    // Add listener for chat messages
    final chatMessagesProvider =
        Provider.of<ChatMessagesProvider>(context, listen: false);
    chatMessagesProvider.addListener(() {
      _scrollToBottom();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 200), () {
      // Small delay
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 100), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    final chatMessagesProvider =
        Provider.of<ChatMessagesProvider>(context, listen: false);
    chatMessagesProvider.removeListener(_scrollToBottom);
    _scrollController.dispose();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) async {
    if (text.isNotEmpty) {
      final chatMessagesProvider =
          Provider.of<ChatMessagesProvider>(context, listen: false);
      chatMessagesProvider.sendMessage(text);
    }
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final chatMessagesProvider = Provider.of<ChatMessagesProvider>(context);

    return Scaffold(
      appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Image.asset('assets/play_store_512.png'), // Path to your logo
          ),
          title: Text('The Animal Whisperer'),
          centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).colorScheme.surfaceContainer,
              Theme.of(context).colorScheme.surfaceContainerHigh,
            ], // Customize your gradient colors here
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: chatMessagesProvider.messages.length +
                    (chatMessagesProvider.waitingForResponse ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= chatMessagesProvider.messages.length) {
                    // This is the additional loading message
                    return AssistantLoadingCard();
                  }
                  final message = chatMessagesProvider.messages[index];
                  if (message.role == 'assistant') {
                    return AssistantMessageCard(message: message.message);
                  } else if (message.role == 'user') {
                    return UserMessageCard(message: message.message);
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
            // if (chatMessagesProvider.waitingForResponse)
            // _buildLoadingIndicator(), // Only show when waiting for a response

            _buildTextComposer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextComposer(BuildContext context) {
    final chatMessagesProvider = Provider.of<ChatMessagesProvider>(context);
    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onSubmitted: _handleSubmitted,
                      decoration: InputDecoration.collapsed(
                        hintText: "Send a message",
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send,
                        color: chatMessagesProvider.waitingForResponse
                            ? Colors.grey
                            : Theme.of(context).colorScheme.onSecondary),
                    onPressed: chatMessagesProvider.waitingForResponse
                        ? null
                        : () => _handleSubmitted(_controller.text),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
              icon: Icon(Icons.phone,
                  color: Theme.of(context).colorScheme.secondary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConversationScreen()),
                );
              })
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: LoadingAnimationWidget.waveDots(
          color: Theme.of(context).colorScheme.primary,
          size: 40,
        ));
  }
}
