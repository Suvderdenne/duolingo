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
        title: Text(
          'Үр дүн',
          style: TextStyle(color: Colors.white), // White text color
        ),
        backgroundColor:
            Color.fromARGB(255, 143, 15, 202), // Set background color
        centerTitle: true, // Center the title
        elevation: 4, // Subtle shadow under the AppBar
        automaticallyImplyLeading: false, // Removes the default back button
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255)
            ],
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

                      bool isCorrect = selectedChoice != null &&
                          selectedChoice['is_correct'] == true;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 6,
                        color: isCorrect
                            ? Colors.green[100]
                            : Colors.red[
                                100], // Soft green for correct, soft red for wrong
                        child: ListTile(
                          title: Text(
                            question['question_text'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            selectedChoice != null
                                ? 'Таны хариулт: ${selectedChoice['text']}'
                                : 'Хариулт сонгоогүй',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Return to the previous page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4, // Slight shadow effect
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
