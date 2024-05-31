import 'package:flutter/material.dart';
import 'screens/text_chat_screen.dart';
import 'models/message.dart';
import 'services/providers/multiprovider_setup.dart';
import 'theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'services/providers/chat_messages_provider/chat_messages_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(AppProviders());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Animal Whisperer',
      theme: AppTheme.greenTheme,
      home: SelectionArea(child: ChatScreen()),
    );
  }
}
