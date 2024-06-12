import 'dart:io';

import 'package:Animal_Whisperer/models/message.dart';
import 'package:Animal_Whisperer/services/providers/authentication_provider.dart';
import 'package:Animal_Whisperer/theme/gradient_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import '../components/chatHistoryDrawer/chat_history_drawer.dart';
import '../components/chatUIcomponents/assistant_message_card.dart';
import '../components/chatUIcomponents/message_card_fade_in.dart';
import '../components/chatUIcomponents/user_message_card.dart';
import '../services/providers/chat_messages_provider/chat_messages_provider.dart';
import 'voice_conversation_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_manager.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<File> _pickedImagesForMessage = [];
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
    Future.delayed(Duration(milliseconds: 100), () {
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
      drawer: ChatHistoryDrawer(),
      appBar: AppBar(
        // leading: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child:
        //       Image.asset('assets/play_store_512.png'), // Path to your logo
        // ),
        title: Text('The Animal Whisperer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.post_add),
            onPressed: () {
              chatMessagesProvider.startNewChat();
            },
          ),
        ],
      ),
      body: GradientContainer(
        child: Column(
          children: [
            text_chat_bubbles_builder(
                scrollController: _scrollController,
                chatMessagesProvider: chatMessagesProvider),
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
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
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

class ExpandableButtonWidget extends StatefulWidget {
  ExpandableButtonWidget({
    super.key,
    required this.addImage,
  });
  final Function(File?) addImage;

  @override
  State<ExpandableButtonWidget> createState() => _ExpandableButtonWidgetState();
}

class _ExpandableButtonWidgetState extends State<ExpandableButtonWidget> {
  bool _isExpanded = false;

  final ImagePicker _picker = ImagePicker();

  void _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      this.widget.addImage(File(image.path));
    }
  }

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      this.widget.addImage(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: _isExpanded ? 146 : 0,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.photo_camera,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: _captureImage,
              ),
              IconButton(
                icon: Icon(
                  Icons.image,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: _pickImage,
              ),
              IconButton(
                icon: Icon(
                  Icons.phone,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () {
                  Future.delayed(Duration(milliseconds: 300), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ),
        IconButton.filled(
          icon: Icon(_isExpanded ? Icons.cancel : Icons.add_circle),
          color: Theme.of(context).colorScheme.secondary,
          iconSize: 32,
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
      ],
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
    return Container(
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
                    child: Icon(
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

class text_chat_bubbles_builder extends StatelessWidget {
  const text_chat_bubbles_builder({
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
