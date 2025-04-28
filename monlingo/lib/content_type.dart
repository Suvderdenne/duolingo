import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'timelapse.dart'; // LessonPage-г импортлоно

class ContentType {
  final int id;
  final String name;
  final String description;

  ContentType({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ContentType.fromJson(Map<String, dynamic> json) {
    return ContentType(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? 'Тайлбар байхгүй',
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/content-types/2/';

  Future<List<ContentType>> fetchContentTypes(int contentTypeId) async {
    final response =
        await http.get(Uri.parse('$baseUrl?language_id=$contentTypeId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      List<ContentType> contentTypes =
          data.map((item) => ContentType.fromJson(item)).toList();

      contentTypes.sort((a, b) {
        if (a.name.trim() == 'шинэ үг') return -1;
        if (b.name.trim() == 'шинэ үг') return 1;
        return 0;
      });

      return contentTypes;
    } else {
      throw Exception('Контентын төрлүүдийг ачааллаж чадсангүй');
    }
  }
}

class ContentTypeListPage extends StatefulWidget {
  final int contentTypeId;

  const ContentTypeListPage({required this.contentTypeId, Key? key})
      : super(key: key);

  @override
  State<ContentTypeListPage> createState() => _ContentTypeListPageState();
}

class _ContentTypeListPageState extends State<ContentTypeListPage> {
  late Future<List<ContentType>> _contentTypes;

  @override
  void initState() {
    super.initState();
    _contentTypes = ApiService().fetchContentTypes(widget.contentTypeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FDFD),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 10,
        title: Text(
          'Контентын төрлүүд',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ContentType>>(
        future: _contentTypes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Алдаа гарлаа: ${snapshot.error}',
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Контентын төрөл олдсонгүй.',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.black87),
              ),
            );
          } else {
            final contentTypes = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: contentTypes.length,
                    itemBuilder: (context, index) {
                      final item = contentTypes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ExpansionTile(
                          leading: const Icon(Icons.menu_book_outlined,
                              color: Colors.teal),
                          title: Text(
                            item.name,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Text(
                                item.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Duolingo(
                            categoryId:
                                widget.contentTypeId, // ✅ Use categoryId
                          ),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Бүх хичээл харах',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
