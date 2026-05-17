import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../config/api_keys.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Hello Farmer! 👨‍🌾 I am FarmBot, your AI farming assistant. I can help you with:\n\n🌱 Crop planning & recommendations\n🌤️ Weather-based farming advice\n🐛 Pest & disease identification\n💰 Market price insights\n\nWhat can I help you with today?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];
  bool _isTyping = false;
  DateTime _lastRequestTime =
      DateTime.now().subtract(const Duration(seconds: 5));
  static const int _requestThrottleSeconds =
      2; // Groq free tier: 30 RPM, 2s gap is safe

  static const String _systemPrompt =
      'You are FarmBot, a friendly and practical AI farming assistant for smallholder farmers in General Trias, Cavite, Philippines (CALABARZON region). '
      'The area has sandy-loam soil and a warm humid climate. '
      'Common crops grown here include sitaw (string beans), ampalaya (bitter gourd), talong (eggplant), kamatis (tomato), pechay, and okra. '
      'Give detailed, actionable advice that is still easy to understand. Use Filipino crop names alongside English. '
      'Use emojis to make responses friendly and easy to read. '
      'Format tips as numbered lists when applicable. '
      'Reference local conditions such as Cavite weather and CALABARZON market prices in Philippine Peso whenever relevant.';

  static const String _webProxyUrl = 'http://localhost:8080/api/gemini';
  static const String _proxyHealthUrl = 'http://localhost:8080/health';

  final List<String> _quickReplies = [
    'What crops should I plant?',
    'Sitaw farming tips',
    'Pest control advice',
    'Best time to harvest?',
    'Market price update',
    'Soil preparation tips',
  ];

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Check rate limiting to avoid quota errors
    final timeSinceLastRequest =
        DateTime.now().difference(_lastRequestTime).inSeconds;
    if (timeSinceLastRequest < _requestThrottleSeconds) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please wait ${_requestThrottleSeconds - timeSinceLastRequest} seconds before sending another message.'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _messages.add(
          ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _isTyping = true;
      _controller.clear();
    });

    _scrollToBottom();

    final response = await _getAIResponse(text);
    _lastRequestTime = DateTime.now();

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
          text: response, isUser: false, timestamp: DateTime.now()));
    });

    _scrollToBottom();
  }

  Future<String> _getAIResponse(String input) async {
    if (kIsWeb) {
      return await _getAIResponseViaProxy(input);
    }

    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.openRouterApiKey}',
          'HTTP-Referer': 'https://farmvaile.app',
          'X-Title': 'FarmvAIle',
        },
        body: jsonEncode({
          'model': 'deepseek/deepseek-v4-flash:free',
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {'role': 'user', 'content': input},
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final text = data['choices']?[0]?['message']?['content'] as String?;
        return text ?? '⚠️ FarmBot received an empty response. Please try again.';
      } else {
        final error = jsonDecode(response.body);
        final message = error['error']?['message'] ?? 'Unknown error (${response.statusCode})';
        if (response.statusCode == 429) {
          return '⚠️ FarmBot is resting! 🌾\n\nFree tier limit reached. Please wait a moment and try again.';
        }
        return '⚠️ FarmBot error: $message';
      }
    } catch (e) {
      return '⚠️ FarmBot connection error: $e';
    }
  }

  Future<String> _getAIResponseViaProxy(String input) async {
    final healthResult = await _checkProxyHealth();
    if (healthResult != null) {
      return healthResult;
    }

    try {
      final response = await http.post(
        Uri.parse(_webProxyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': input}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final text = _extractGeminiText(data);
        if (text == null) {
          return '⚠️ FarmBot received an empty response from the proxy. Please try again.';
        }
        return text;
      }

      final error = jsonDecode(response.body);
      final message = error['error']?['message'] ??
          'Proxy failure (${response.statusCode})';
      return '⚠️ FarmBot proxy error: $message\n\nIs the backend running at $_webProxyUrl?';
    } catch (e) {
      return '⚠️ FarmBot connection error: ${e.runtimeType}: $e\n\nMake sure the proxy server is running and the URL is reachable from your browser.\nRun the backend with `cd backend && npm install && npm start`, then refresh the app.';
    }
  }

  Future<String?> _checkProxyHealth() async {
    try {
      final response = await http.get(Uri.parse(_proxyHealthUrl));
      if (response.statusCode != 200) {
        return '⚠️ FarmBot proxy health check failed: HTTP ${response.statusCode}.\nMake sure the backend is running at $_proxyHealthUrl and has GEMINI_API_KEY configured.';
      }

      final healthData = jsonDecode(response.body);
      if (healthData is Map && healthData['apiKeySet'] == false) {
        return '⚠️ FarmBot proxy is running, but GEMINI_API_KEY is not configured.\nSet GEMINI_API_KEY in backend environment variables and restart the proxy.';
      }

      return null;
    } catch (e) {
      return '⚠️ FarmBot proxy health check failed: ${e.runtimeType}: $e\nMake sure the backend is running with `cd backend && npm install && npm start`, then refresh the app.';
    }
  }

  String? _extractGeminiText(dynamic data) {
    if (data is! Map) return null;

    // Surface API-level errors clearly instead of crashing
    final errorField = data['error'];
    if (errorField is Map) {
      final code = errorField['code'];
      final msg = errorField['message'] ?? 'Unknown Gemini API error';
      if (code == 429 || msg.toString().toLowerCase().contains('quota')) {
        // Extract retry delay from message if present
      final retryMatch = RegExp(r'retry in ([\d.]+)s').firstMatch(msg.toString());
      final retrySeconds = retryMatch != null
          ? ' Please wait ${retryMatch.group(1)!.split('.')[0]}s before trying again.'
          : ' Please wait 30 seconds before trying again.';
      return '⚠️ FarmBot is resting! 🌾\n\nFree tier limit reached.$retrySeconds\n\nTip: The free plan allows ~2 messages per minute.';
      }
      return '⚠️ FarmBot API error ($code): $msg';
    }

    // Standard Gemini response format
    final candidates = data['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      final first = candidates[0];
      if (first is Map) {
        final content = first['content'];
        if (content is Map) {
          final parts = content['parts'];
          if (parts is List && parts.isNotEmpty) {
            final part = parts[0];
            if (part is Map) {
              final text = part['text'];
              if (text is String) return text;
            }
          }
        }
      }
    }

    return null;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmTheme.backgroundGrey,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('🤖', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FarmBot AI',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text('Powered by Gemini AI • Gen. Trias, Cavite',
                    style: TextStyle(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (_isTyping && i == _messages.length) {
                  return const _TypingIndicator();
                }
                return _MessageBubble(message: _messages[i]);
              },
            ),
          ),

          // Quick replies — show only at the start
          if (_messages.length <= 2)
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickReplies.length,
                itemBuilder: (ctx, i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(_quickReplies[i],
                          style: const TextStyle(fontSize: 12)),
                      backgroundColor: FarmTheme.paleGreen,
                      side: const BorderSide(color: FarmTheme.softGreen),
                      onPressed: () => _sendMessage(_quickReplies[i]),
                    ),
                  );
                },
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.06),
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask FarmBot anything...',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: _sendMessage,
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _sendMessage(_controller.text),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: FarmTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: FarmTheme.primaryGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? FarmTheme.primaryGreen : FarmTheme.cardWhite,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.06),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : FarmTheme.textDark,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: FarmTheme.softGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                  child: Text('👨‍🌾', style: TextStyle(fontSize: 16))),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: FarmTheme.primaryGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: FarmTheme.cardWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('FarmBot is thinking',
                    style: TextStyle(fontSize: 12, color: FarmTheme.textLight)),
                SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  child: LinearProgressIndicator(
                    color: FarmTheme.primaryGreen,
                    backgroundColor: FarmTheme.paleGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
