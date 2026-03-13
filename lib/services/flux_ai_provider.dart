import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/flux_chat_message.dart';
import 'flux_ai_state.dart';

// NOTE: Do not commit a real key here in production.
const _openAiApiKey = '';

class FluxAiProvider extends ChangeNotifier {
  FluxAiState _state = const FluxAiState();

  FluxAiState get state => _state;

  void _setState(FluxAiState newState) {
    _state = newState;
    notifyListeners();
  }

  void addWelcomeMessage() {
    if (_state.messages.isNotEmpty) return;

    final nextMessages = [
      ..._state.messages,
      FluxChatMessage.ai(
        'Hello there! 👋 I am **Flux**, your ClgJone academic assistant.\n\n'
        'How can I help you today? I can find **AKTU Notes**, generate **Learning Roadmaps**, or provide **Documentation Links**.',
        isMarkdown: true,
      ),
    ];
    _setState(_state.copyWith(messages: nextMessages));
  }

  Future<void> sendMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty || _state.isLoading) return;

    _setState(
      _state.copyWith(
        messages: [..._state.messages, FluxChatMessage.user(trimmed)],
        isLoading: true,
        autoScroll: true,
      ),
    );

    try {
      final reply = await _getAiResponse(trimmed);
      _setState(
        _state.copyWith(
          messages: [
            ..._state.messages,
            FluxChatMessage.ai(reply, isMarkdown: true),
          ],
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Flux AI error: $e');
      }
      _setState(
        _state.copyWith(
          messages: [
            ..._state.messages,
            FluxChatMessage.ai(
              '⚠️ Sorry, I encountered an error processing your request. '
              'Please try again or check your connection.',
            ),
          ],
        ),
      );
    } finally {
      _setState(_state.copyWith(isLoading: false));
    }
  }

  Future<String> _getAiResponse(String message) async {
    if (_openAiApiKey.isEmpty) {
      return _getFallbackResponse(message);
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_openAiApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are Flux, an academic assistant inside the ClgJone app. '
                      'You help with AKTU notes, learning roadmaps, official docs, and GitHub links. '
                      'Respond concisely using Markdown, bullet points, and emojis as needed.',
            },
            {
              'role': 'user',
              'content': message,
            },
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            data['choices']?[0]?['message']?['content'] as String?;
        if (content != null && content.isNotEmpty) {
          return content;
        }
      }

      return _getFallbackResponse(message);
    } catch (_) {
      return _getFallbackResponse(message);
    }
  }

  String _getFallbackResponse(String message) {
    final lower = message.toLowerCase();

    // --- AKTU Notes Finder -------------------------------------------------
    final hasAktu = lower.contains('aktu');
    final hasNotes = lower.contains('notes');
    final subjectCodeMatch =
        RegExp(r'\b[a-z]{2}\s?\d{3}\b', caseSensitive: false)
            .firstMatch(lower);

    if (hasAktu || hasNotes || subjectCodeMatch != null) {
      String subject = 'AKTU B.Tech Subject';
      String semester = 'Not specified';
      String notesUrl = 'https://notesgallery.com/b-tech-aktu/';

      // Try to infer year / semester from text
      if (lower.contains('1st') || lower.contains('first year')) {
        semester = '1st Year';
        notesUrl = 'https://notesgallery.com/b-tech-aktu/1st-year';
      } else if (lower.contains('2nd') || lower.contains('second year')) {
        semester = '2nd Year';
        notesUrl = 'https://notesgallery.com/b-tech-aktu/2nd-year';
      } else if (lower.contains('3rd') || lower.contains('third year')) {
        semester = '3rd Year';
        notesUrl = 'https://notesgallery.com/b-tech-aktu/3rd-year';
      } else if (lower.contains('4th') || lower.contains('fourth year')) {
        semester = '4th Year';
        notesUrl = 'https://notesgallery.com/b-tech-aktu/4th-year';
      }

      if (subjectCodeMatch != null) {
        subject = subjectCodeMatch.group(0)!.toUpperCase();
      }

      return '''📚 Subject: $subject
🎓 Semester: $semester

Download Notes:
$notesUrl

Source: [Note Gallery](https://notesgallery.com/b-tech-aktu/)  
_(If this link doesn't match your exact subject, search by code or subject name on Note Gallery.)_''';
    }

    // --- Roadmap.sh style learning paths ----------------------------------
    if (lower.contains('flutter')) {
      return '''🚀 Learning Path: Flutter Development

1️⃣ Roadmap  
https://roadmap.sh/flutter

2️⃣ Official Documentation  
https://docs.flutter.dev

3️⃣ GitHub Learning Resources  
- https://github.com/flutter/flutter  
- https://github.com/Solido/awesome-flutter  

4️⃣ Beginner Guide  
- Learn Dart basics  
- Build simple UIs and navigation  
- Learn state management  
- Connect APIs / Firebase  
- Publish 1–2 real apps.''';
    }

    if (lower.contains('frontend') ||
        lower.contains('front-end') ||
        lower.contains('front end') ||
        lower.contains('web dev') ||
        lower.contains('web development')) {
      return '''🚀 Learning Path: Frontend Development

1️⃣ Roadmap  
https://roadmap.sh/frontend

2️⃣ Official Documentation  
- HTML/CSS: https://developer.mozilla.org/en-US/docs/Web  
- React: https://react.dev  

3️⃣ GitHub Learning Resources  
- https://github.com/kamranahmedse/developer-roadmap  
- https://github.com/enaqx/awesome-react  

4️⃣ Beginner Guide  
- Learn HTML & CSS + responsive design  
- Learn modern JavaScript (ES6+, DOM, async/await)  
- Pick a framework (React/Next.js, Vue, or Angular) and build 3–4 projects  
- Learn APIs, auth, and state management  
- Deploy with Vercel/Netlify and iterate.''';
    }

    if (lower.contains('backend')) {
      return '''🚀 Learning Path: Backend Development

1️⃣ Roadmap  
https://roadmap.sh/backend

2️⃣ Official Documentation  
- https://nodejs.org/en/docs  
- https://expressjs.com/  

3️⃣ GitHub Learning Resources  
- https://github.com/kamranahmedse/developer-roadmap  
- https://github.com/donnemartin/system-design-primer  

4️⃣ Beginner Guide  
- Pick one language (JS/TS, Python, or Java)  
- Learn HTTP + REST APIs and JSON  
- Build CRUD APIs with a DB (PostgreSQL/MongoDB)  
- Add authentication and validation  
- Learn deployment (Render/Railway) and basic system design.''';
    }

    if (lower.contains('devops')) {
      return '''🚀 Learning Path: DevOps Engineering

1️⃣ Roadmap  
https://roadmap.sh/devops

2️⃣ Official Documentation  
- Docker: https://docs.docker.com/  
- Kubernetes: https://kubernetes.io/docs/  

3️⃣ GitHub Learning Resources  
- https://github.com/kamranahmedse/developer-roadmap  

4️⃣ Beginner Guide  
- Learn Linux & shell basics  
- Learn Git, CI/CD, and Docker  
- Practice deploying apps to a cloud provider  
- Add Kubernetes, monitoring, and IaC (Terraform/Ansible).''';
    }

    if (lower.contains('cybersecurity') || lower.contains('cyber security')) {
      return '''🚀 Learning Path: Cybersecurity

1️⃣ Roadmap  
https://roadmap.sh/cyber-security

2️⃣ Official Documentation / Resources  
- https://owasp.org/  
- https://www.sans.org/  

3️⃣ GitHub Learning Resources  
- https://github.com/kamranahmedse/developer-roadmap  

4️⃣ Beginner Guide  
- Learn networking and Linux basics  
- Study OWASP Top 10 and web security  
- Practice with CTF platforms (Hack The Box, TryHackMe)  
- Learn tools (Burp, Nmap, Metasploit) and report writing.''';
    }

    if (lower.contains('data science') ||
        lower.contains('data scientist') ||
        lower.contains('ai engineer') ||
        lower.contains('machine learning')) {
      return '''🚀 Learning Path: Data Science / AI

1️⃣ Roadmap  
https://roadmap.sh/ai-data-scientist

2️⃣ Official Documentation / Resources  
- Python: https://docs.python.org/3/  
- scikit-learn: https://scikit-learn.org/  

3️⃣ GitHub Learning Resources  
- https://github.com/kamranahmedse/developer-roadmap  

4️⃣ Beginner Guide  
- Learn Python and statistics basics  
- Learn NumPy, Pandas, Matplotlib/Seaborn  
- Practice ML with scikit-learn on real datasets  
- Build and document 3–4 small ML projects.''';
    }

    // Generic academic helper
    return '''Thanks for your question! 🤔

I'm Flux, your academic assistant in ClgJone.

I can help you with:
- **AKTU notes & documentation links**  
- **Learning roadmaps** (Flutter, Backend, Frontend, DevOps, AI, Cybersecurity)  
- **Career guidance & study resources**  

Examples you can try:
- "AKTU 1st year notes"
- "CS301 AKTU notes"
- "Flutter roadmap"
- "Backend development roadmap"
- "DevOps learning path"''';
  }
}

