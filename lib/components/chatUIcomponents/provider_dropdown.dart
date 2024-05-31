import 'package:flutter/material.dart';
import '../../models/chatbot_provider.dart';
import 'api_key_modal.dart';

class ProviderDropdown extends StatefulWidget {
  final List<ChatbotProvider> providers;
  final ChatbotProvider selectedProvider;
  final Function(ChatbotProvider) onProviderChanged;

  ProviderDropdown({
    required this.providers,
    required this.selectedProvider,
    required this.onProviderChanged,
  });

  @override
  _ProviderDropdownState createState() => _ProviderDropdownState();
}

class _ProviderDropdownState extends State<ProviderDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<ChatbotProvider>(
      value: widget.selectedProvider,
      onChanged: (value) {
        if (value != null) {
          widget.onProviderChanged(value);
          showDialog(
            context: context,
            builder: (context) => ApiKeyModal(provider: value),
          );
        }
      },
      items: widget.providers
          .map<DropdownMenuItem<ChatbotProvider>>((ChatbotProvider provider) {
        return DropdownMenuItem<ChatbotProvider>(
          value: provider,
          child: Text(provider.name),
        );
      }).toList(),
    );
  }
}
