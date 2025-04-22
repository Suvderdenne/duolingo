import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'lesson_content_page.dart'; // Import the LessonContentPage

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
        title: Text('Monlingo'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Арын зураг
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Градиент давхарга
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.6),
                  Colors.blueAccent.withOpacity(0.3),
                  Colors.purpleAccent.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Контентууд
          contentTypes.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 100, 16, 16),
                  itemCount: contentTypes.length,
                  itemBuilder: (context, index) {
                    final type = contentTypes[index];
                    final int typeId = type['id'];
                    final List<dynamic>? lessons = lessonsByType[typeId];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: Colors.white.withOpacity(0.85),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              type['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            leading: Icon(Icons.category, color: Colors.deepPurple),
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
                                      // Navigate to the LessonContentPage with the lesson ID
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LessonContentPage(lessonId: lesson['id']),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      color: Colors.white.withOpacity(0.8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Container(
                                        width: 350,
                                        padding: EdgeInsets.all(4),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.memory(
                                                Base64Decoder().convert(lesson['thumbnail_base64']),
                                                width: 350,
                                                height: 180,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.5),
                                                  borderRadius: BorderRadius.only(
                                                    bottomLeft: Radius.circular(8),
                                                    bottomRight: Radius.circular(8),
                                                  ),
                                                ),
                                                child: Text(
                                                  lesson['title'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
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
                              child: Text(
                                'No lessons available for this category',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                )
              : Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}
