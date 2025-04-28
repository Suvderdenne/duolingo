import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'header_footer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'leaderboard.dart';

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
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/languages/'));

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
          color: Colors.white, // Changed from gradient to plain white
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Image.asset(
                        'home/abc.png',
                        height: 40,
                      ),
                    ),
                    const SizedBox(height: 86),
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 150),
                          child: Center(
                            child: Lottie.asset(
                              'home/lot.json',
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          left: 16,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(seconds: 2),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 30),
                                  child: Text(
                                    'Хэлээ сонгоно ингэсэн үү дээ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                          255, 143, 15, 202),
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.black.withOpacity(0.6),
                                          offset: Offset(2.0, 2.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    FutureBuilder<List<Language>>(
                      future: languages,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No languages found.'));
                        } else {
                          List<Language> languageList = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.0,
                                ),
                                itemCount: languageList.length,
                                itemBuilder: (context, index) {
                                  final language = languageList[index];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LeaderboardPG(
                                              languageCode: language.code),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(
                                            255, 143, 15, 202), // Soft purple
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 8,
                                            offset: Offset(2, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.memory(
                                              base64Decode(language.flagBase64),
                                              width: 100,
                                              height: 70,
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
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
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
