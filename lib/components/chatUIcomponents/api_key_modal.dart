import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/chatbot_provider.dart';

class ApiKeyModal extends StatefulWidget {
  final ChatbotProvider provider;

  ApiKeyModal({required this.provider});

  @override
  _ApiKeyModalState createState() => _ApiKeyModalState();
}

class _ApiKeyModalState extends State<ApiKeyModal> {
  final TextEditingController _apiKeyController = TextEditingController();
  final storage = FlutterSecureStorage();

  void _saveApiKey() async {
    await storage.write(
        key: widget.provider.name, value: _apiKeyController.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: Text('Enter API Key for ${widget.provider.name}',
          style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              controller: _apiKeyController,
              autofocus: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'API Key',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Your API key is encrypted and stored locally on your device, no online record is kept of your API keys.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel', style: TextStyle(color: Colors.white)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Save', style: TextStyle(color: Colors.white)),
          onPressed: _saveApiKey,
        ),
      ],
    );
  }
}
