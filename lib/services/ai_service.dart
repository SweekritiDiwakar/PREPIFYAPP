import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  const AiService();

  Future<String> sendMessageToAI(String message) async {
    final trimmed = message.trim();

    if (trimmed.isEmpty) {
      return 'Please type a question so I can help.';
    }

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        return 'It looks like your GEMINI_API_KEY is missing from the .env file. Please add it to use the AI assistant.';
      }

      final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
      
      final prompt = 'You are a helpful culinary assistant for the Prepify app. '
          'Help the user with recipes, cooking tips, or grocery management. '
          'User message: $trimmed';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      return response.text ?? 'Sorry, I could not generate a response right now.';
    } catch (e) {
      debugPrint('AiService.sendMessageToAI error: $e');
      return 'Sorry, there was an error connecting to the AI service. Please try again later.';
    }
  }
}
