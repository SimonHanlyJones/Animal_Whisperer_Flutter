import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/signIn/sign_in_screen.dart';
import 'screens/chat/textChat/text_chat_screen.dart';
import 'services/providers/authentication_provider.dart';
import 'services/providers/multiprovider_setup.dart';
import 'theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");

  runApp(const AppProviders());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return MaterialApp(
      title: 'The Animal Whisperer',
      theme: AppTheme.greenTheme,
      home: SelectionArea(
        child: authProvider.currentUser != null ? const ChatScreen() : const SignInPage(),
      ),
    );
  }
}
