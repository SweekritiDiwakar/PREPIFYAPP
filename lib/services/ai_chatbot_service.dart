import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiChatbotService {
  late final GenerativeModel _model;
  late ChatSession _chatSession;

  // 🔐 Secure API key (from .env file)
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // ignore: unused_field
  final String _systemInstructions = '''
You are a friendly food assistant chatbot.

Talk in simple, clear, and short sentences.
Use easy words so anyone can understand.

You help users with:
- Food recipes
- Ingredients
- Cooking tips
- Healthy meal suggestions
- Food substitutions

Rules:
- Keep answers short and helpful
- Avoid complex or technical terms
- If explaining a recipe, give step-by-step instructions
- If suggesting food, keep it practical and easy to make
- Be friendly and casual

Example tone:
"Try making a simple chicken rice. Cook rice, fry chicken with salt and spices, and mix together. Easy and tasty!"

If the question is not food-related, still try to help in context of cooking, groceries, or household food management.
''';

  AiChatbotService() {
   _model = GenerativeModel(
  model: 'gemini-2.5-flash',
  apiKey: _apiKey,
  // no requestOptions needed
);

    _chatSession = _model.startChat();
  }

  /// Reset chat (useful for new household / new session)
  void resetChat() {
    _chatSession = _model.startChat();
  }

  Future<String> sendMessage(String text) async {
    // ⚠️ API key validation
    if (_apiKey.isEmpty || !_apiKey.startsWith('AIza')) {
      await Future.delayed(const Duration(seconds: 1));
      return "⚠️ AI is not configured yet. Please add your Gemini API key in .env file.";
    }

    try {
      final response = await _chatSession
          .sendMessage(Content.text(text))
          .timeout(const Duration(seconds: 20));

      return response.text?.trim() ??
          "Hmm I couldn't think of a reply, Try again!";
    } on TimeoutException {
      debugPrint('Gemini API timeout');
      return "The chatbot is taking too long to respond. Please try again.";
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      return "AI error: ${e.toString()}";
    }
  }
}