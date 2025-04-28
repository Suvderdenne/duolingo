import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'timelapse.dart'; // Duolingo хуудас

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
        title: Text(
          'Хэлний түвшин',
          style: TextStyle(color: Colors.white), // White text color
        ),
        backgroundColor:
            Color.fromARGB(255, 143, 15, 202), // Set background color
        centerTitle: true, // Center the title
        elevation: 4, // Subtle shadow under the AppBar
        automaticallyImplyLeading: false, // Removes the default back button
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255), // Light purple
              Color.fromARGB(255, 206, 206, 206), // Medium purple
              Color.fromARGB(255, 255, 255, 255), // Deep purple
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
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Colors.deepPurple));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Алдаа гарлаа: ${snapshot.error}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Контент олдсонгүй.',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  } else {
                    List<ContentType> contentList = snapshot.data!;
                    return ListView.builder(
                      itemCount: contentList.length,
                      itemBuilder: (context, index) {
                        ContentType content = contentList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Card(
                            color: Colors.deepPurple[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 6,
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors
                                    .transparent, // Remove expansion divider
                              ),
                              child: ExpansionTile(
                                leading: const Icon(Icons.language,
                                    color: Colors.white, size: 28),
                                title: Text(
                                  content.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      content.description ??
                                          'Тайлбар алга байна.',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Duolingo()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                icon: const Icon(Icons.school, size: 28, color: Colors.white),
                label: const Text(
                  'Хичээл үзэх',
                  style: TextStyle(fontSize: 20, color: Colors.white),
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
