import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/providers/authentication_provider.dart';
import '../../theme/gradient_container.dart';

class newAccountScreen extends StatelessWidget {
  const newAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: GradientContainer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Create account with email and password
                  try {
                    await Provider.of<AuthenticationProvider>(context,
                            listen: false)
                        .createAccountWithEmail(
                            emailController.text, passwordController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account created successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create account: $e')),
                    );
                  }
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
