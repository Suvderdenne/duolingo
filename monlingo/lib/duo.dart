import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'quiz_model.dart'; // Quiz болон QuizChoice классуудыг импортлоно
// Моделуудыг дотроо бичнэ
class Quiz {
  final int id;
  final String question;
  final String? audioBase64;
  final List<QuizChoice> choices;

  Quiz({
    required this.id,
    required this.question,
    required this.audioBase64,
    required this.choices,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    var choicesJson = json['choices'] as List<dynamic>;
    List<QuizChoice> parsedChoices =
        choicesJson.map((c) => QuizChoice.fromJson(c)).toList();

    return Quiz(
      id: json['id'],
      question: json['question'],
      audioBase64: json['audio_base64'],
      choices: parsedChoices,
    );
  }
}

class QuizChoice {
  final int id;
  final String text;
  final bool isCorrect;

  QuizChoice({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory QuizChoice.fromJson(Map<String, dynamic> json) {
    return QuizChoice(
      id: json['id'],
      text: json['text'],
      isCorrect: json['is_correct'],
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<List<Quiz>> quizzes;
  Map<int, QuizChoice> selectedChoices = {};
  bool showResults = false;

  @override
  void initState() {
    super.initState();
    quizzes = fetchQuizzes();
  }

  Future<List<Quiz>> fetchQuizzes() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/quizzes/'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => Quiz.fromJson(item)).toList();
    } else {
      throw Exception('Асуултуудыг ачааллахад алдаа гарлаа');
    }
  }

  Future<void> playAudio(String base64Audio) async {
    final audioPlayer = AudioPlayer();
    Uint8List audioBytes = base64Decode(base64Audio);
    await audioPlayer.play(BytesSource(audioBytes));
  }

  void calculateResults(List<Quiz> quizList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultPage(
          quizList: quizList,
          selectedChoices: selectedChoices,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF7F9FC),
      appBar: AppBar(
        title: Text("🧠 Сорил"),
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Quiz>>(
        future: quizzes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
          } else if (snapshot.hasError) {
            return Center(child: Text('Алдаа: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Асуултууд байхгүй.'));
          } else {
            List<Quiz> quizList = snapshot.data!;
            int correctAnswers = selectedChoices.entries
                .where((entry) =>
                    quizList
                        .firstWhere((quiz) => quiz.id == entry.key)
                        .choices
                        .firstWhere((choice) => choice.id == entry.value.id)
                        .isCorrect)
                .length;

            return SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  ...quizList.map((quiz) {
                    List<QuizChoice> shuffledChoices = List.from(quiz.choices)..shuffle();

                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: EdgeInsets.symmetric(vertical: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quiz.question,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            if (quiz.audioBase64 != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: ElevatedButton.icon(
                                  onPressed: () => playAudio(quiz.audioBase64!),
                                  icon: Icon(Icons.volume_up),
                                  label: Text("Сонсох"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple[100],
                                    foregroundColor: Colors.black87,
                                  ),
                                ),
                              ),
                            SizedBox(height: 14),
                            Column(
                              children: shuffledChoices.map((choice) {
                                bool isSelected = selectedChoices[quiz.id]?.id == choice.id;
                                bool isCorrect = choice.isCorrect;

                                Color backgroundColor = Colors.grey.shade100;
                                Color borderColor = Colors.grey.shade300;
                                IconData? icon;

                                if (showResults && isSelected) {
                                  if (isCorrect) {
                                    backgroundColor = Colors.green.shade300;
                                    borderColor = Colors.green;
                                    icon = Icons.check_circle;
                                  } else {
                                    backgroundColor = Colors.red.shade300;
                                    borderColor = Colors.red;
                                    icon = Icons.cancel;
                                  }
                                } else if (isSelected) {
                                  backgroundColor = Colors.deepPurple.shade100;
                                  borderColor = Colors.deepPurple;
                                }

                                return GestureDetector(
                                  onTap: () {
                                    if (!showResults) {
                                      setState(() {
                                        selectedChoices[quiz.id] = choice;
                                      });
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    padding: EdgeInsets.all(14),
                                    margin: EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: backgroundColor,
                                      border: Border.all(color: borderColor),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(choice.text,
                                              style: TextStyle(fontSize: 16)),
                                        ),
                                        if (icon != null)
                                          Icon(icon, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            if (selectedChoices[quiz.id] != null && showResults)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  selectedChoices[quiz.id]!.isCorrect
                                      ? '🎉 Зөв хариулт!'
                                      : '❌ Буруу хариулт!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: selectedChoices[quiz.id]!.isCorrect
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: selectedChoices.length == quizList.length
                        ? () => calculateResults(quizList)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    child: Text("📊 Дүн харах", style: TextStyle(fontSize: 18)),
                  ),
                  if (showResults)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(),
                          Text(
                            "Нийт оноо: $correctAnswers / ${quizList.length}",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          if (correctAnswers != quizList.length)
                            Text(
                              "Дараах асуултад буруу хариулсан байна:",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ...quizList.where((quiz) {
                            QuizChoice? selected = selectedChoices[quiz.id];
                            return selected != null && !selected.isCorrect;
                          }).map((quiz) {
                            QuizChoice correctChoice =
                                quiz.choices.firstWhere((c) => c.isCorrect);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                "• ${quiz.question}\n   ✅ Зөв хариулт: ${correctChoice.text}",
                                style: TextStyle(fontSize: 15),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class QuizResultPage extends StatelessWidget {
  final List<Quiz> quizList;
  final Map<int, QuizChoice> selectedChoices;

  const QuizResultPage({
    required this.quizList,
    required this.selectedChoices,
  });

  @override
  Widget build(BuildContext context) {
    int correctAnswers = selectedChoices.entries.where((entry) {
      final quiz = quizList.firstWhere((quiz) => quiz.id == entry.key);
      final selected = entry.value;
      return quiz.choices.firstWhere((c) => c.id == selected.id).isCorrect;
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('📊 Үр дүн'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Таны оноо: $correctAnswers / ${quizList.length}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: quizList.map((quiz) {
                  QuizChoice correct =
                      quiz.choices.firstWhere((c) => c.isCorrect);
                  QuizChoice? selected = selectedChoices[quiz.id];

                  return Card(
                    color: (selected != null && selected.id == correct.id)
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(quiz.question),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("✅ Зөв хариулт: ${correct.text}"),
                          if (selected != null && selected.id != correct.id)
                            Text("❌ Таны хариулт: ${selected.text}"),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("↩ Буцах"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
