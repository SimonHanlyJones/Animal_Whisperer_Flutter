import 'dart:io';

import 'package:Animal_Whisperer/theme/gradient_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/chatHistoryDrawer/chat_history_drawer.dart';
import 'textChatComponents/assistant_message_card.dart';
import 'textChatComponents/blank_screen_content.dart';
import 'textChatComponents/expandable_button_widget.dart';
import 'textChatComponents/message_card_fade_in.dart';
import 'textChatComponents/user_message_card.dart';
import '../../../services/providers/chat_messages_provider/chat_messages_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<File> _pickedImagesForMessage = [];
  // final ImagePicker _picker = ImagePicker();

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

  void _removeImage(int index) {
    setState(() {
      _pickedImagesForMessage.removeAt(index);
    });
  }

  void _addImage(File? image) {
    if (image != null) {
      setState(() {
        _pickedImagesForMessage.add(image);
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      // Small delay
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
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
    if (text.isNotEmpty || _pickedImagesForMessage.isNotEmpty) {
      final chatMessagesProvider =
          Provider.of<ChatMessagesProvider>(context, listen: false);

      // print(imageUrls);
      // await Future.delayed(Duration(seconds: 1));

      chatMessagesProvider.sendMessage(
          text: text, images: _pickedImagesForMessage);
    }
    _controller.clear();
    setState(() {
      _pickedImagesForMessage.clear();
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final chatMessagesProvider = Provider.of<ChatMessagesProvider>(context);

    return Scaffold(
      drawer: const ChatHistoryDrawer(),
      appBar: AppBar(
        title: const Text('The Animal Whisperer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.post_add,
              color: chatMessagesProvider.waitingForResponse ||
                      chatMessagesProvider.waitingForImages
                  ? Colors.grey
                  : Theme.of(context).colorScheme.onSecondary,
            ),
            onPressed: chatMessagesProvider.waitingForResponse ||
                    chatMessagesProvider.waitingForImages
                ? null
                : () => chatMessagesProvider.startNewChat(),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: GradientContainer(
        child: Column(
          children: [
            chatMessagesProvider.messages.length <= 1 &&
                    !chatMessagesProvider.waitingForImages &&
                    !chatMessagesProvider.waitingForResponse
                ? const BlankScreenContent()
                : TextChatBubblesBuilder(
                    scrollController: _scrollController,
                    chatMessagesProvider: chatMessagesProvider),
            SafeArea(child: _buildTextComposer(context)),
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
      child: Column(
        children: [
          if (_pickedImagesForMessage.isNotEmpty)
            PickedImagesDisplay(
              pickedImagesForMessage: _pickedImagesForMessage,
              onRemoveImage: _removeImage,
            ),
          Row(
            children: [
              Row(
                children: [
                  ExpandableButtonWidget(
                    addImage: _addImage,
                  )
                ],
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onSubmitted: _handleSubmitted,
                          maxLines: 5,
                          minLines: 1,
                          decoration: InputDecoration.collapsed(
                            hintText: "Message",
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
            ],
          ),
        ],
      ),
    );
  }
}

class PickedImagesDisplay extends StatelessWidget {
  const PickedImagesDisplay({
    super.key,
    required this.pickedImagesForMessage,
    required this.onRemoveImage,
  });

  final List<File> pickedImagesForMessage;
  final Function(int) onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pickedImagesForMessage.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  pickedImagesForMessage[index],
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () => onRemoveImage(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TextChatBubblesBuilder extends StatelessWidget {
  const TextChatBubblesBuilder({
    super.key,
    required ScrollController scrollController,
    required this.chatMessagesProvider,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final ChatMessagesProvider chatMessagesProvider;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          controller: _scrollController,
          itemCount: chatMessagesProvider.messages.length +
              (chatMessagesProvider.waitingForResponse ? 1 : 0) +
              (chatMessagesProvider.waitingForImages ? 1 : 0),
          itemBuilder: (context, index) {
            Widget card;
            if (index >= chatMessagesProvider.messages.length &&
                chatMessagesProvider.waitingForResponse) {
              // This is the additional loading message
              return FadeInListItem(child: AssistantLoadingCard());
            } else if (index >= chatMessagesProvider.messages.length &&
                chatMessagesProvider.waitingForImages) {
              return FadeInListItem(child: UserLoadingCard());
            }
            final message = chatMessagesProvider.messages[index];
            if (message.role == 'assistant') {
              card = AssistantMessageCard(message: message);
            } else if (message.role == 'user') {
              card = UserMessageCard(message: message);
            } else {
              return const SizedBox.shrink();
            }
            return FadeInListItem(child: card);
          }),
    );
  }
}
