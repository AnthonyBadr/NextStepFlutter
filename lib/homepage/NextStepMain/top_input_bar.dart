import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'aac_types.dart'; // Your TileData class

class BottomSentenceBar extends StatefulWidget {
  final List<TileData> selected;

  const BottomSentenceBar({super.key, required this.selected});

  @override
  State<BottomSentenceBar> createState() => _BottomSentenceBarState();
}

class _BottomSentenceBarState extends State<BottomSentenceBar> {
  String _lastSentence = '';

  @override
  void initState() {
    super.initState();
    OpenAI.apiKey = const String.fromEnvironment('OPENAI_API_KEY');
  }

  @override
  void didUpdateWidget(covariant BottomSentenceBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = _buildSentence(widget.selected);
    if (current.isNotEmpty && current != _lastSentence) {
      _lastSentence = current;
      _classifyAndShow(current);
    }
  }

  String _buildSentence(List<TileData> tiles) =>
      tiles.map((e) => e.text).join(' ').trim();

  Future<void> _classifyAndShow(String sentence) async {
    dev.log('📤 Sending to GPT: $sentence');

    try {
      final result = await OpenAI.instance.chat.create(
        model: 'gpt-4o',
        temperature: 0,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                '''
You are an AAC INTENT CLASSIFIER for non-verbal individuals using a speech-assistive app.

Your job is to analyze the user's message and output ONE intent label in UPPER_SNAKE_CASE with NO punctuation or explanation.

RULES:
- NEED_<THING>        → if it's a request or desire (e.g. "I want juice" → NEED_JUICE)
- STATE_<STATE>       → if it expresses emotion or physical feeling (e.g. "I'm tired" → STATE_TIRED)
- QUESTION_<TOPIC>    → for questions (e.g. "Where are you?" → QUESTION_LOCATION)
- SOCIAL_<ACT>        → for greetings, thanks, etc. (e.g. "Thank you" → SOCIAL_THANKS)
- COMMAND_<ACTION>    → for orders (e.g. "Come here" → COMMAND_COME)
- ALERT_<TYPE>        → for self-harm, violence, or danger
    - "I want to hurt myself"     → ALERT_SELF_HARM
    - "I will hit you"            → ALERT_VIOLENCE
    - "There is a fire!"          → ALERT_DANGER
- INFO_<TOPIC>        → for neutral facts ("The sky is blue" → INFO_SKY)
- EXPRESSION_<TYPE>   → for emotional noises or cheering ("Yay!" → EXPRESSION_EXCITEMENT)
- MEMORY_<TOPIC>      → for recalling past events
- UNCLEAR             → if the sentence is confusing or nonsense

EXTRA RULE:
If this sentence is similar to one you've seen before, always reuse the same label.

Return ONLY the label. No quotes. No explanation.
''',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(sentence),
            ],
          ),
        ],
      );

      final intent = result.choices.first.message.content
          ?.map((e) => e.text)
          .join(' ')
          .trim();

      dev.log('✅ GPT Classification: "$sentence" → $intent');

      if (mounted) _showSnack('Intent: $intent', Colors.blueGrey.shade800);
    } catch (e, st) {
      dev.log('❌ GPT classification failed', error: e, stackTrace: st);

      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (mounted) _showSnack('⚠️ GPT error: $errorMsg', Colors.redAccent);
    }
  }

  void _showSnack(String msg, Color bg) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: bg,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final sentence = _buildSentence(widget.selected);

    return Material(
      color: Colors.grey.shade100,
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        width: double.infinity,
        child: Text(
          sentence.isEmpty ? 'Sentence will appear here' : sentence,
          style: TextStyle(
            fontSize: 18,
            color: sentence.isEmpty ? Colors.grey.shade400 : Colors.black,
          ),
        ),
      ),
    );
  }
}
