import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/authentication_provider.dart';

class ChatHistoryDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Text(
              'Chat History',
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
    );
  }

  // Drawer content for signed in user
  Widget _buildUserDrawer(BuildContext context) {
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
