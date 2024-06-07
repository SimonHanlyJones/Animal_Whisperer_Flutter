class Message {
  final DateTime time;
  final String role; // 'assistant', 'user', or 'system'
  String? text;
  final List<String> imageUrls;

// default empty image list and time = now
  Message({
    DateTime? time,
    required this.role,
    this.text,
    List<String>? imageUrls,
  })  : time = time ?? DateTime.now(),
        imageUrls = imageUrls ?? [];

  void addText(String newText) {
    text = newText;
  }

  void addImageUrl(String imageUrl) {
    imageUrls.add(imageUrl);
  }

  Map<String, dynamic> toOpenAIAPI() {
    if (imageUrls.isEmpty) {
      // Case when there are no image URLs
      return {
        'role': role,
        'content': text ?? '',
      };
    } else {
      // Case when there are one or more image URLs
      List<Map<String, dynamic>> contents = [];
      if (text != null) {
        contents.add({
          'type': 'text',
          'text': text!,
        });
      }
      for (var url in imageUrls) {
        contents.add({
          'type': 'image_url',
          'image_url': {'url': url, "detail": "low"},
        });
      }
      return {
        'role': role,
        'content': contents,
      };
    }
  }
}


// EXAMPLE IMAGE REQUEST
// curl https://api.openai.com/v1/chat/completions \
//   -H "Content-Type: application/json" \
//   -H "Authorization: Bearer API_TOKEN" \
//   -d '{
//     "model": "gpt-4o",
//     "messages": [
//       {
//         "role": "system",
//         "content": "You are a helpful animal expert called the Animal Whisperer. Your job is to help the user with all of their animal care questions. Do so in a funny, overenthusiastic, Australian manner like a famous Australian Crocodile Hunter."
//       },      
// {
//         "role": "user",
//         "content": [
//           {
//             "type": "text",
//             "text": "What'\''s in this image?"
//           },
//           {
//             "type": "image_url",
//             "image_url": {
//               "url": "https://firebasestorage.googleapis.com/v0/b/animalwhispererflutter.appspot.com/o/user%2FoNCXq5NssXfYvJFEvMOLySyG2pI3%2F1717642643542.jpg?alt=media&token=0564f4cf-26fa-4e04-b4ca-700307e0aac8"
//             }
//           }
//         ]
//       }
//     ],
//     "max_tokens": 300
//   }'
