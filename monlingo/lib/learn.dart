import 'package:flutter/material.dart';
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
  bool _isTranslated = false;
  String _errorMessage = "";

  // Translate function using Google Translate API
  Future<void> translateSentence(String sentence) async {
    final apiKey = 'AIzaSyDGan9Ue6OTYfeMnyXz1qhoB68NPYuvgEk';
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
      setState(() {
        _originalWords = translatedText.split(' ');
        _shuffledWords = List.from(_originalWords);
        _shuffledWords.shuffle();
        _isTranslated = true;
        _errorMessage = "";
      });
    } else {
      setState(() {
        _isTranslated = false;
        _errorMessage = "Error translating sentence.";
      });
    }
  }

  // Check if the sentence is in correct order
  bool checkAnswer() {
    return _shuffledWords.join(' ') == _originalWords.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sentence Learning'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter a sentence in any language',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
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
                children: [
                  Text(
                    'Rearrange the words:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  DragAndDropWords(
                    words: _shuffledWords,
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
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Try again!')),
                        );
                      }
                    },
                    child: Text('Check Answer'),
                  ),
                ],
              )
            else if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}

class DragAndDropWords extends StatefulWidget {
  final List<String> words;
  final Function(List<String>) onRearranged;

  DragAndDropWords({required this.words, required this.onRearranged});

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
                  backgroundColor: Colors.blue.shade100,
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: Chip(label: Text(word)),
              ),
              child: Chip(label: Text(word)),
            );
          },
        );
      }),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SentenceLearningPage(),
  ));
}
