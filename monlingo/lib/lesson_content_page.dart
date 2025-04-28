import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class LessonContent {
  final String text;
  final String? imageBase64;
  final String? audioBase64;

  LessonContent({required this.text, this.imageBase64, this.audioBase64});

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      text: json['text'] ?? '',
      imageBase64: json['image_base64'],
      audioBase64: json['audio_base64'],
    );
  }
}

class LessonContentPage extends StatefulWidget {
  final int lessonId;

  LessonContentPage({required this.lessonId});

  @override
  _LessonContentPageState createState() => _LessonContentPageState();
}

class _LessonContentPageState extends State<LessonContentPage> {
  late Future<List<LessonContent>> _lessonContents;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _expandedImageIndex;

  @override
  void initState() {
    super.initState();
    _lessonContents = fetchLessonContents(widget.lessonId);
  }

  Future<List<LessonContent>> fetchLessonContents(int lessonId) async {
    final url = 'http://127.0.0.1:8000/lesson-content/$lessonId/';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonData.map((item) => LessonContent.fromJson(item)).toList();
    } else {
      throw Exception('Контентыг ачааллахад алдаа гарлаа');
    }
  }

  Future<void> playBase64Audio(String base64Audio) async {
    Uint8List audioBytes = base64Decode(base64Audio);
    await _audioPlayer.play(BytesSource(audioBytes));
  }

  void openFullImage(Uint8List imageBytes, String tag) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black54,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(color: Colors.black45),
              ),
            ),
            Center(
              child: Hero(
                tag: tag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.memory(
                    imageBytes,
                    width: MediaQuery.of(context).size.width * 0.9,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfef8f8), // Light pastel background
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent.shade100,
        elevation: 0,
        title: Text(
          '🎈 Сурах',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<LessonContent>>(
        future: _lessonContents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Алдаа: ${snapshot.error}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Контент олдсонгүй.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
            );
          } else {
            List<LessonContent> contents = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: contents.length,
              itemBuilder: (context, index) {
                LessonContent content = contents[index];
                String tag = 'image_$index';
                Uint8List? imageBytes = content.imageBase64 != null ? base64Decode(content.imageBase64!) : null;

                return AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (content.text.isNotEmpty)
                              Text(
                                content.text,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            SizedBox(height: 16),
                            if (imageBytes != null)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _expandedImageIndex = (_expandedImageIndex == index) ? null : index;
                                  });
                                  openFullImage(imageBytes, tag);
                                  if (content.audioBase64 != null) {
                                    playBase64Audio(content.audioBase64!);
                                  }
                                },
                                child: Hero(
                                  tag: tag,
                                  child: AnimatedScale(
                                    scale: _expandedImageIndex == index ? 1.2 : 1.0,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Image.memory(
                                            imageBytes,
                                            height: 220,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        if (content.audioBase64 != null)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircleAvatar(
                                              backgroundColor: Colors.pinkAccent,
                                              child: Icon(Icons.volume_up, color: Colors.white),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
