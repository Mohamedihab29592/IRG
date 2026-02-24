import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class TranslationService {
  static const String _groqApiKey = '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';
  static const String _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static Future<String> translateText({
    required String text,
    String sourceLang = 'ar',
    String targetLang = 'en',
  }) async {
    if (text.trim().isEmpty) return '';
    return await _groqTranslate(text);
  }

  static Future<String> _groqTranslate(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: json.encode({
          'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          'messages': [
            {
              'role': 'system',
              'content':
              'You are a professional translator specializing in security and incident reports. '
                  'Translate Arabic text to formal professional English. '
                  'Rules:\n'
                  '- Translate EVERY single word completely, no matter how long the text\n'
                  '- Use formal professional tone for official security reports\n'
                  '- Preserve names, numbers, ID codes exactly as-is\n'
                  '- Do NOT skip, summarize, or omit any part\n'
                  '- Return ONLY the translated text, no explanations or notes\n'
                  '- Translate "أسلحة بيضاء" or "white weapons" as "edged weapons" or "bladed weapons"\n' // ✅ fix this term
                  '- Translate "سلاح أبيض" as "bladed weapon"'
            },
            {
              'role': 'user',
              'content': text,
            }
          ],
          'temperature': 0.1,
          'max_tokens': 8192,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content == null || content.toString().trim().isEmpty) {
          throw Exception('Empty translation response');
        }
        return content.toString().trim();
      } else {
        final errorData = json.decode(response.body);
        final errorMsg = errorData['error']?['message'] ?? 'Unknown error';
        throw Exception('Groq API error ${response.statusCode}: $errorMsg');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Translation timed out. Please try again.');
    } catch (e) {
      throw Exception('Translation failed: $e');
    }
  }
}