// translation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // Try these alternative LibreTranslate instances
  static const List<String> libreTranslateUrls = [
    'https://translate.terraprint.co',       // Community instance
    'https://libretranslate.com',           // Alternative
  ];

  static int currentUrlIndex = 0;
  static const int maxChunkSize = 1000;

  static Future<String> translateText({
    required String text,
    String sourceLang = 'ar',
    String targetLang = 'en',
  }) async {
    if (text.isEmpty) return '';

    if (text.length > maxChunkSize) {
      return await _translateLongText(text, sourceLang, targetLang);
    }

    return await _translateChunk(text, sourceLang, targetLang);
  }

  static Future<String> _translateChunk(
      String text,
      String sourceLang,
      String targetLang,
      ) async {
    // Try each URL until one works
    for (int i = 0; i < libreTranslateUrls.length; i++) {
      try {
        final urlIndex = (currentUrlIndex + i) % libreTranslateUrls.length;
        final baseUrl = libreTranslateUrls[urlIndex];

        final response = await http.post(
          Uri.parse('$baseUrl/translate'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'q': text,
            'source': sourceLang,
            'target': targetLang,
            'format': 'text',
            'api_key': '', // Some instances don't require API key
          }),
        ).timeout(Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          currentUrlIndex = urlIndex; // Remember working URL
          return data['translatedText'];
        }
      } catch (e) {
        print('Failed with URL ${libreTranslateUrls[(currentUrlIndex + i) % libreTranslateUrls.length]}: $e');
        continue; // Try next URL
      }
    }

    // If all LibreTranslate instances fail, fallback to MyMemory
    return await _fallbackTranslation(text, sourceLang, targetLang);
  }

  // Fallback to MyMemory API (no key required, very reliable)
  static Future<String> _fallbackTranslation(
      String text,
      String sourceLang,
      String targetLang,
      ) async {
    try {
      final uri = Uri.parse('https://api.mymemory.translated.net/get').replace(
        queryParameters: {
          'q': text,
          'langpair': '$sourceLang|$targetLang',
          'de': 'your_email@example.com', // Optional: improves limits
        },
      );

      final response = await http.get(uri).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translatedText = data['responseData']['translatedText'];

        // MyMemory returns "QUERY LENGTH LIMIT EXCEEDED" for long texts
        if (translatedText.contains('QUERY LENGTH LIMIT EXCEEDED')) {
          throw Exception('Text too long for translation');
        }

        return translatedText;
      } else {
        throw Exception('Translation failed');
      }
    } catch (e) {
      throw Exception('All translation services failed: $e');
    }
  }

  static Future<String> _translateLongText(
      String text,
      String sourceLang,
      String targetLang,
      ) async {
    // Split text intelligently
    List<String> chunks = _splitTextIntoChunks(text, maxChunkSize);
    List<String> translatedChunks = [];

    for (int i = 0; i < chunks.length; i++) {
      try {
        String translated = await _translateChunk(
          chunks[i],
          sourceLang,
          targetLang,
        );
        translatedChunks.add(translated);

        print('Translated ${i + 1}/${chunks.length} chunks');

        // Delay between requests to avoid rate limiting
        if (i < chunks.length - 1) {
          await Future.delayed(Duration(milliseconds: 500));
        }
      } catch (e) {
        print('Error translating chunk ${i + 1}: $e');
        // Continue with partial translation
        translatedChunks.add('[Translation failed for this section]');
      }
    }

    return translatedChunks.join(' ');
  }

  static List<String> _splitTextIntoChunks(String text, int maxSize) {
    List<String> chunks = [];

    // First try to split by paragraphs
    List<String> paragraphs = text.split('\n\n');

    for (String paragraph in paragraphs) {
      if (paragraph.length <= maxSize) {
        chunks.add(paragraph);
      } else {
        // Split long paragraphs by sentences
        List<String> sentences = paragraph.split(RegExp(r'[.!?؟،]\s*'));
        String currentChunk = '';

        for (String sentence in sentences) {
          if (sentence.isEmpty) continue;

          if ((currentChunk + sentence).length <= maxSize) {
            currentChunk += sentence + '. ';
          } else {
            if (currentChunk.isNotEmpty) {
              chunks.add(currentChunk.trim());
            }

            // If single sentence is too long, split by words
            if (sentence.length > maxSize) {
              List<String> words = sentence.split(' ');
              String wordChunk = '';

              for (String word in words) {
                if ((wordChunk + word).length <= maxSize) {
                  wordChunk += word + ' ';
                } else {
                  if (wordChunk.isNotEmpty) {
                    chunks.add(wordChunk.trim());
                  }
                  wordChunk = word + ' ';
                }
              }

              if (wordChunk.isNotEmpty) {
                currentChunk = wordChunk;
              }
            } else {
              currentChunk = sentence + '. ';
            }
          }
        }

        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk.trim());
        }
      }
    }

    return chunks;
  }
}