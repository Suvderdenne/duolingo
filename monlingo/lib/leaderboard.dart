import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'header_footer.dart';

class LeaderboardPG extends StatefulWidget {
  const LeaderboardPG({super.key});

  @override
  State<LeaderboardPG> createState() => _LeaderboardPGState();
}

class _LeaderboardPGState extends State<LeaderboardPG> {
  late Future<List<ContentType>> contentTypes;

  @override
  void initState() {
    super.initState();
    contentTypes = fetchContentTypes();
  }

  Future<List<ContentType>> fetchContentTypes() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/content-types/1/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => ContentType.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load content types');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leaderboard"),
      ),
      body: Container(
        // Adding gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 207, 74, 207),
              Color.fromARGB(255, 88, 207, 207),
              Color.fromARGB(255, 81, 255, 148),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<ContentType>>(
          future: contentTypes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No content found.'));
            } else {
              List<ContentType> contentList = snapshot.data!;
              return ListView.builder(
                itemCount: contentList.length,
                itemBuilder: (context, index) {
                  ContentType content = contentList[index];
                  return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 2,
                      child: ExpansionTile(
                        leading: Icon(Icons.language, size: 28),
                        title: Text(
                          content.name,
                          style: TextStyle(
                            fontSize: 20,             // Гарчиг томруулсан
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              content.description ?? 'No description available',
                              style: TextStyle(
                                fontSize: 16,           // Тайлбар жоохон том
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: Footer(),
    );
  }
}

class ContentType {
  final int id;
  final String name;
  final String? description;

  ContentType({required this.id, required this.name, this.description});

  factory ContentType.fromJson(Map<String, dynamic> json) {
    return ContentType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
