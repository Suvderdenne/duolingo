import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Duolingo extends StatefulWidget {
  const Duolingo({super.key});

  @override
  _DuolingoState createState() => _DuolingoState();
}

class _DuolingoState extends State<Duolingo> {
  List<dynamic> contentTypes = [];
  Map<int, List<dynamic>> lessonsByType = {}; // Lessons grouped by content type

  @override
  void initState() {
    super.initState();
    _fetchContentTypes();
  }

  // Fetch content types from API
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

  // Fetch lessons for all content types at once
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
      appBar: AppBar(
        title: Text('Duolingo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 207, 74, 207),
              Color.fromARGB(255, 88, 207, 207),
              Color.fromARGB(255, 81, 255, 148),
            ],
          ),
        ),
        child: contentTypes.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: contentTypes.length,
                itemBuilder: (context, index) {
                  final type = contentTypes[index];
                  final int typeId = type['id'];
                  final List<dynamic>? lessons = lessonsByType[typeId];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.white.withOpacity(0.8), // Make cards semi-transparent
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            type['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          leading: Icon(Icons.category),
                        ),
                        if (lessons != null && lessons.isNotEmpty)
                          Container(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: lessons.length,
                              itemBuilder: (context, index) {
                                var lesson = lessons[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  color: Colors.white.withOpacity(0.8), // Make cards semi-transparent
                                  child: Container(
                                    width: 160,
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.memory(
                                            Base64Decoder().convert(lesson['thumbnail_base64']),
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          lesson['title'],
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
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
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              )
            : Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}
