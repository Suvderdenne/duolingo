import 'package:flutter/material.dart';
import 'package:login_flutter/start.dart';
import 'package:lottie/lottie.dart';
import 'header_footer.dart';
import 'Profile.dart';
import 'duo.dart';
import 'timelapse.dart';
import 'leaderboard.dart';
import 'login.dart';
import 'dart:convert'; // json болон base64Decode-г оруулж байгаа
import 'package:http/http.dart' as http; // http-г оруулж байгаа

class Language {
  final String name;
  final String code;
  final String flagBase64;

  Language({required this.name, required this.code, required this.flagBase64});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['name'],
      code: json['code'],
      flagBase64: json['flag_base64'],
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Language>> languages;

  @override
  void initState() {
    super.initState();
    languages = fetchLanguages();
  }

  Future<List<Language>> fetchLanguages() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/languages/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Language.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load languages');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.fromARGB(255, 207, 74, 207),
                Color.fromARGB(255, 88, 207, 207),
                Color.fromARGB(255, 81, 255, 148),
              ],
            ),
          ),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<List<Language>>(
                  future: languages,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No languages found.'));
                    } else {
                      List<Language> languageList = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Languages:',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true, // Жижиглэхийн тулд
                            physics: NeverScrollableScrollPhysics(), // Scroll-гүй болгох
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 эгнээтэй болгох
                              crossAxisSpacing: 10, // Эгнээ хоорондын зай
                              mainAxisSpacing: 10, // Хонгилын зай
                              childAspectRatio: 1.0, // Элементийн харьцааг тохируулна
                            ),
                            itemCount: languageList.length,
                            itemBuilder: (context, index) {
                              final language = languageList[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        base64Decode(language.flagBase64),
                                        width: 120, // Өндөр болон өргөнийг жижиглэнэ
                                        height: 80, 
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      language.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(),
    );
  }
}
