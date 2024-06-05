import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/providers/authentication_provider.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Sign in with email and password
                try {
                  await Provider.of<AuthenticationProvider>(context,
                          listen: false)
                      .signInWithEmail(
                          emailController.text, passwordController.text);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to sign in: $e')),
                  );
                }
              },
              child: Text('Sign In with Email'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                // Sign in with Google
                try {
                  await Provider.of<AuthenticationProvider>(context,
                          listen: false)
                      .signInWithGoogle();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to sign in with Google: $e')),
                  );
                }
              },
              child: Text('Sign In with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
