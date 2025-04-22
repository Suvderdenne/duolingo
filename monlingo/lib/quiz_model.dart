class Quiz {
  final int id;
  final String question;
  final String? audioBase64;
  final List<QuizChoice> choices;

  Quiz({
    required this.id,
    required this.question,
    this.audioBase64,
    required this.choices,
  });

  // Factory method to create Quiz instance from JSON
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

  // Convert Quiz object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'audio_base64': audioBase64,
      'choices': choices.map((choice) => choice.toJson()).toList(),
    };
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

  // Factory method to create QuizChoice instance from JSON
  factory QuizChoice.fromJson(Map<String, dynamic> json) {
    return QuizChoice(
      id: json['id'],
      text: json['text'],
      isCorrect: json['is_correct'],
    );
  }

  // Convert QuizChoice object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'is_correct': isCorrect,
    };
  }
}
