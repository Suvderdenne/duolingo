import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'lesson_content_page.dart';
import 'duo.dart'; // QuizPage-г import хийсэн байгаа

class Duolingo extends StatefulWidget {
  const Duolingo({super.key});

  @override
  _DuolingoState createState() => _DuolingoState();
}

class _DuolingoState extends State<Duolingo> {
  List<dynamic> contentTypes = [];
  Map<int, List<dynamic>> lessonsByType = {};

  @override
  void initState() {
    super.initState();
    _fetchContentTypes();
  }

  Future<void> _fetchContentTypes() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/content-types/2/'));
    if (response.statusCode == 200) {
      setState(() {
        contentTypes = List<dynamic>.from(json.decode(utf8.decode(response.bodyBytes)));
      });
      _fetchLessonsForAllContentTypes();
    } else {
      throw Exception('Failed to load content types');
    }
  }

  Future<void> _fetchLessonsForAllContentTypes() async {
    for (var type in contentTypes) {
      final contentTypeId = type['id'];
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/lessons/$contentTypeId/'));

      if (response.statusCode == 200) {
        setState(() {
          lessonsByType[contentTypeId] = List<dynamic>.from(json.decode(utf8.decode(response.bodyBytes)));
        });
      } else {
        throw Exception('Failed to load lessons for content type $contentTypeId');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Monlingo',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purpleAccent.shade100,
                  Colors.blueAccent.shade100,
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          contentTypes.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 100, 16, 16),
                  itemCount: contentTypes.length,
                  itemBuilder: (context, index) {
                    final type = contentTypes[index];
                    final int typeId = type['id'];
                    final List<dynamic>? lessons = lessonsByType[typeId];

                    return Card(
                      elevation: 8,
                      shadowColor: Colors.deepPurpleAccent.withOpacity(0.3),
                      margin: EdgeInsets.symmetric(vertical: 12),
                      color: Colors.white.withOpacity(0.85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Icon(Icons.category, color: Colors.deepPurple, size: 32),
                            title: Text(
                              type['name'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuizPage(contentTypeId: typeId),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              child: Text('Quiz', style: GoogleFonts.poppins(color: Colors.white)),
                            ),
                          ),
                          if (lessons != null && lessons.isNotEmpty)
                            Container(
                              height: 220,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: lessons.length,
                                itemBuilder: (context, index) {
                                  var lesson = lessons[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LessonContentPage(lessonId: lesson['id']),
                                        ),
                                      );
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Stack(
                                          children: [
                                            Image.memory(
                                              Base64Decoder().convert(lesson['thumbnail_base64']),
                                              width: 350,
                                              height: 180,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                color: Colors.black45,
                                                child: Text(
                                                  lesson['title'],
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Text(
                                  'No lessons available for this category',
                                  style: GoogleFonts.poppins(color: Colors.black87),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                )
              : Center(
                  child: CircularProgressIndicator(
                    color: Colors.deepPurpleAccent,
                    strokeWidth: 5,
                  ),
                ),
        ],
      ),
    );
  }
}
