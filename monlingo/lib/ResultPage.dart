import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final List<dynamic> quizQuestions;
  final Map<int, dynamic> selectedChoices;

  const ResultPage({
    Key? key,
    required this.quizQuestions,
    required this.selectedChoices,
  }) : super(key: key);

  int _calculateScore() {
    int score = 0;
    selectedChoices.forEach((index, selectedChoice) {
      if (selectedChoice != null && selectedChoice['is_correct'] == true) {
        score++;
      }
    });
    return score;
  }

  @override
  Widget build(BuildContext context) {
    int totalQuestions = quizQuestions.length;
    int score = _calculateScore();

    return Scaffold(
      appBar: AppBar(
        title: Text('Үр дүн'),
        backgroundColor: Colors.purpleAccent,
        automaticallyImplyLeading: false, // Уламжлалт буцах товчийг устгана
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0ED2F7), Color(0xFFB2FEFA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Таны оноо: $score / $totalQuestions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: quizQuestions.length,
                    itemBuilder: (context, index) {
                      var question = quizQuestions[index];
                      var selectedChoice = selectedChoices[index];

                      bool isCorrect = selectedChoice != null && selectedChoice['is_correct'] == true;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 6,
                        color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                        child: ListTile(
                          title: Text(
                            question['question_text'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            selectedChoice != null
                                ? 'Таны хариулт: ${selectedChoice['text']}'
                                : 'Хариулт сонгоогүй',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Буцах код
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Буцах',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
