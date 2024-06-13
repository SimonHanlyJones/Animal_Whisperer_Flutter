import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/providers/authentication_provider.dart';
import '../../theme/gradient_container.dart';
import 'new_account_screen.dart';

class SignInPage extends StatefulWidget {
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with WidgetsBindingObserver {
  double avatarRadius = 200.0;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0.0;
    _updateAvatarSize(isKeyboardVisible);
  }

  void _updateAvatarSize(bool isKeyboardVisible) {
    setState(() {
      avatarRadius = isKeyboardVisible ? 40.0 : 200.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In Here Mate!"),
      ),
      body: GradientContainer(
        child: Column(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                backgroundImage: AssetImage(
                    'assets/animan512.png'), // Make sure to add your image in the assets folder
              ),
            ),
            Padding(
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
                        emailController.clear();
                        passwordController.clear();
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
                              content:
                                  Text('Failed to sign in with Google: $e')),
                        );
                      }
                    },
                    child: Text('Sign In with Google'),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => newAccountScreen()),
                      );
                    },
                    child: Text('Create an Account'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _KeyboardVisibilityObserver extends WidgetsBindingObserver {
//   final _SignInPageState _state;

//   _KeyboardVisibilityObserver(this._state);

//   @override
//   void didChangeMetrics() {
//     final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
//     final isKeyboardVisible = bottomInset > 0.0;
//     _state._updateAvatarSize(isKeyboardVisible);
//   }
// }
