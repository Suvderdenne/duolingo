import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'timelapse.dart'; // Duolingo хуудсыг import хийж байна

class LeaderboardPG extends StatefulWidget {
  final String languageCode;

  const LeaderboardPG({super.key, required this.languageCode});

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
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/content-types/${widget.languageCode}/'),
    );

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
        title: const Text("Leaderboard"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
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
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<ContentType>>(
                future: contentTypes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Алдаа: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Контент олдсонгүй.'));
                  } else {
                    List<ContentType> contentList = snapshot.data!;
                    return ListView.builder(
                      itemCount: contentList.length,
                      itemBuilder: (context, index) {
                        ContentType content = contentList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ExpansionTile(
                            leading: const Icon(Icons.language, size: 28, color: Colors.deepPurple),
                            title: Text(
                              content.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  content.description ?? 'Тайлбар алга байна.',
                                  style: const TextStyle(
                                    fontSize: 16,
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Duolingo()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.school, color: Colors.white),
                label: const Text(
                  'Хичээл үзэх',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Контент загвар ----
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
