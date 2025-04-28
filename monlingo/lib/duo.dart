import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'resultpage.dart';

class QuizPage extends StatefulWidget {
  final int contentTypeId;

  const QuizPage({Key? key, required this.contentTypeId}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<dynamic> quizQuestions = [];
  Map<int, dynamic> selectedChoices = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuizQuestions();
  }

  Future<void> _fetchQuizQuestions() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8000/quiz-by-contenttype/${widget.contentTypeId}/'),
      );

      if (response.statusCode == 200) {
        setState(() {
          quizQuestions = json.decode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load quiz questions');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _goToResultPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          quizQuestions: quizQuestions,
          selectedChoices: selectedChoices,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Асуулт бөглөх',
          style: TextStyle(color: Colors.white), // White text color
        ),
        backgroundColor:
            Color.fromARGB(255, 143, 15, 202), // Set background color
        centerTitle: true, // Center the title
        elevation: 4, // Subtle shadow under the AppBar
        automaticallyImplyLeading: false, // Removes the default back button
      ),
      body: Container(
        color: Colors.white, // Set background color to white
        child: SafeArea(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : quizQuestions.isEmpty
                  ? Center(child: Text('Асуулт олдсонгүй'))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: quizQuestions.length,
                              itemBuilder: (context, index) {
                                var question = quizQuestions[index];
                                var choices = question['choices'] ?? [];

                                choices.shuffle();

                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 8,
                                  margin: EdgeInsets.symmetric(vertical: 12),
                                  color: Color.fromARGB(
                                      255, 143, 15, 202), // Purple card color
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Асуулт ${index + 1}: ${question['question_text'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // White text for contrast
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Column(
                                          children:
                                              choices.map<Widget>((choice) {
                                            return Container(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                              ),
                                              child: RadioListTile<dynamic>(
                                                title: Text(
                                                  choice['text'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                value: choice,
                                                groupValue:
                                                    selectedChoices[index],
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedChoices[index] =
                                                        value;
                                                  });
                                                },
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _goToResultPage,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                backgroundColor:
                                    Colors.deepPurple, // Button color
                                elevation: 4, // Subtle shadow
                              ),
                              child: Text(
                                'Шалгах',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white, // Text color white
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
