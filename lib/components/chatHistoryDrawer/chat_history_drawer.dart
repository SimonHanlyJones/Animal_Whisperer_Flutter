import 'package:Animal_Whisperer/services/providers/chat_messages_provider/chat_messages_provider.dart';
import 'package:Animal_Whisperer/theme/gradient_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/authentication_provider.dart';

class ChatHistoryDrawer extends StatelessWidget {
  const ChatHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return Drawer(
      child: GradientContainer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 144,
              child: DrawerHeader(
                decoration:
                    BoxDecoration(color: Theme.of(context).colorScheme.primary),
                child: Text(
                  'Tail Tales',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            authProvider.currentUser != null
                ? _buildUserDrawer(context)
                : _buildSignInDrawer(context),
          ],
        ),
      ),
    );
  }

  // Drawer content for signed in user
  Widget _buildUserDrawer(BuildContext context) {
    final ChatMessagesProvider chatMessagesProvider =
        Provider.of<ChatMessagesProvider>(context);
    return Column(
      children: <Widget>[
        ...chatMessagesProvider.chatHistory.map((session) {
          return GestureDetector(
            onLongPress: () async {
              bool? confirmDelete = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Delete Chat"),
                    content: const Text(
                        "Are you sure you want to delete this chat?"),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: const Text("Delete"),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );

              if (confirmDelete == true) {
                chatMessagesProvider.deleteChatSession(session.id);
              }
            },
            child: Container(
              // color: Theme.of(context).colorScheme.secondary,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                title: Text(session.title ?? "Title Tinkering...",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  chatMessagesProvider.loadChatFromHistory(session.id);
                },
              ),
            ),
          );
        }),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Sign Out'),
          onTap: () {
            Provider.of<AuthenticationProvider>(context, listen: false)
                .signOut();
            Navigator.pop(context); // Optionally close the drawer
          },
        ),
      ],
    );
  }

  // Drawer content for non-signed in user
  Widget _buildSignInDrawer(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.login),
      title: const Text('Sign In'),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.pushNamed(context, '/signin'); // Navigate to the sign-in page
      },
    );
  }
}
