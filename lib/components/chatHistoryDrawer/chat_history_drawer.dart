import 'package:Animal_Whisperer/services/providers/chat_messages_provider/chat_messages_provider.dart';
import 'package:Animal_Whisperer/theme/gradient_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/authentication_provider.dart';

class ChatHistoryDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Drawer(
      child: GradientContainer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
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
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () {
            Navigator.pop(context); // Close the drawer
            // Navigate to Home or any other action
          },
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('Profile'),
          onTap: () {
            Navigator.pop(context); // Close the drawer
            // Navigate to Profile or any other action
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            Navigator.pop(context); // Close the drawer
            // Navigate to Settings or any other action
          },
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Sign Out'),
          onTap: () {
            Provider.of<AuthenticationProvider>(context, listen: false)
                .signOut();
            Navigator.pop(context); // Optionally close the drawer
          },
        ),
        ...chatMessagesProvider.chatHistory.map((session) {
          return GestureDetector(
            onLongPress: () async {
              bool? confirmDelete = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Delete Chat"),
                    content: Text("Are you sure you want to delete this chat?"),
                    actions: <Widget>[
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: Text("Delete"),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chat deleted')),
                );
              }
            },
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
          );
        }).toList(),
      ],
    );
  }

  // Drawer content for non-signed in user
  Widget _buildSignInDrawer(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.login),
      title: Text('Sign In'),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.pushNamed(context, '/signin'); // Navigate to the sign-in page
      },
    );
  }
}
