import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SentenceLearningPage extends StatefulWidget {
  @override
  _SentenceLearningPageState createState() => _SentenceLearningPageState();
}

class _SentenceLearningPageState extends State<SentenceLearningPage> {
  TextEditingController _controller = TextEditingController();
  List<String> _shuffledWords = [];
  List<String> _originalWords = [];
  List<String> _previousSentences = [];

  bool _isTranslated = false;
  bool _isPlaying = false;
  bool _isCompleted = false;
  String _errorMessage = "";
  String _detectedLanguageCode = "";

  Future<void> translateSentence(String sentence) async {
    final apiKey = 'AIzaSyAxm_DqXsLMKvEfzk82oq6UqEwcjNHD2e8'; // Replace with your API key
    final url =
        'https://translation.googleapis.com/language/translate/v2?key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'q': sentence,
        'target': 'en',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final translatedText = data['data']['translations'][0]['translatedText'];
      final detectedLanguage =
          data['data']['translations'][0]['detectedSourceLanguage'];

      setState(() {
        _originalWords = translatedText.split(' ');
        _shuffledWords = List.from(_originalWords)..shuffle();
        _isTranslated = true;
        _isPlaying = true;
        _isCompleted = false;
        _errorMessage = "";
        _detectedLanguageCode = detectedLanguage;
        _previousSentences.add(sentence.trim());
        _controller.clear();
      });
    } else {
      setState(() {
        _isTranslated = false;
        _errorMessage = "Error translating sentence.";
      });
    }
  }

  String getLanguageName(String code) {
    const languageMap = {
      'en': 'English',
      'mn': 'Mongolian',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'zh': 'Chinese',
      'ru': 'Russian',
      'ja': 'Japanese',
      'ko': 'Korean',
      // Add more as needed
    };

    return languageMap[code] ?? code;
  }

  bool checkAnswer() {
    return _shuffledWords.join(' ') == _originalWords.join(' ');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shuffle the words/Үгсийг холих',
          style: GoogleFonts.poppins(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor:  Color.fromARGB(255, 143, 15, 202),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 56),
              if (!_isPlaying)
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Enter a sentence in any language',
                    border: OutlineInputBorder(),
                  ),
                ),
              SizedBox(height: 56),
              if (!_isPlaying)
                ElevatedButton(
                  onPressed: () {
                    final sentence = _controller.text.trim();
                    if (sentence.isNotEmpty) {
                      translateSentence(sentence);
                    }
                  },
                  child: Text('Translate'),
                ),
              SizedBox(height: 16),
              if (_isTranslated)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detected Language: ${getLanguageName(_detectedLanguageCode)}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.deepPurple,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Rearrange the words:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    DragAndDropWords(
                      words: _shuffledWords,
                      originalWords: _originalWords,
                      onRearranged: (rearrangedWords) {
                        setState(() {
                          _shuffledWords = rearrangedWords;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (checkAnswer()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Correct!')),
                          );
                          setState(() {
                            _isCompleted = true;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Try again!')),
                          );
                        }
                      },
                      child: Text('Check Answer'),
                    ),
                    if (_isCompleted) ...[
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isPlaying = false;
                            _isTranslated = false;
                            _shuffledWords.clear();
                            _originalWords.clear();
                          });
                        },
                        child: Text('Next Sentence'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              if (_previousSentences.isNotEmpty) ...[
                SizedBox(height: 24),
                Text(
                  'Previous Sentences:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                ..._previousSentences
                    .map((s) => Text("• $s", style: TextStyle(fontSize: 14)))
                    .toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DragAndDropWords extends StatefulWidget {
  final List<String> words;
  final List<String> originalWords;
  final Function(List<String>) onRearranged;

  DragAndDropWords({
    required this.words,
    required this.originalWords,
    required this.onRearranged,
  });

  @override
  _DragAndDropWordsState createState() => _DragAndDropWordsState();
}

class _DragAndDropWordsState extends State<DragAndDropWords> {
  late List<String> _words;

  @override
  void initState() {
    super.initState();
    _words = List.from(widget.words);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final word = _words.removeAt(oldIndex);
      _words.insert(newIndex, word);
    });
    widget.onRearranged(_words);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_words.length, (index) {
        final word = _words[index];
        final isCorrect = widget.originalWords.length > index &&
            word == widget.originalWords[index];

        return DragTarget<int>(
          onWillAccept: (fromIndex) => fromIndex != index,
          onAccept: (fromIndex) {
            _onReorder(fromIndex, index);
          },
          builder: (context, candidateData, rejectedData) {
            return Draggable<int>(
              data: index,
              feedback: Material(
                color: Colors.transparent,
                child: Chip(
                  label: Text(word),
                  backgroundColor: isCorrect
                      ? Colors.green.shade300
                      : Colors.grey.shade300,
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: Chip(
                  label: Text(word),
                  backgroundColor: isCorrect
                      ? Colors.green.shade300
                      : Colors.grey.shade300,
                ),
              ),
              child: Chip(
                label: Text(word),
                backgroundColor: isCorrect
                    ? Colors.green.shade300
                    : Colors.grey.shade300,
              ),
            );
          },
        );
      }),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SentenceLearningPage(),
  ));
}
