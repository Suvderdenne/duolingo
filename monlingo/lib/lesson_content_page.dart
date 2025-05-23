import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class LessonContent {
  final String description; // Сурсны агуулга тайлбар
  final String? base64Image; // Зургийн base64
  final String? base64Audio; // Аудио base64

  LessonContent(
      {required this.description, this.base64Image, this.base64Audio});

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      description: json['text'] ?? '',
      base64Image: json['image_base64'],
      base64Audio: json['audio_base64'],
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
  late Future<List<LessonContent>> _lessonContentList;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _lessonContentList = fetchLessonContents(widget.lessonId);
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

  Future<void> playAudioFromBase64(String base64Audio) async {
    Uint8List audioBytes = base64Decode(base64Audio);
    await _audioPlayer.play(BytesSource(audioBytes));
  }

  void openFullScreenImage(Uint8List imageBytes, String tag) {
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
      backgroundColor: Color(0xFFfef8f8),
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent.shade100,
        elevation: 0,
        title: Text(
          '🎈 Сурах',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<LessonContent>>(
        future: _lessonContentList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Colors.pinkAccent));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Алдаа: ${snapshot.error}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Контент олдсонгүй.',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey),
              ),
            );
          } else {
            List<LessonContent> contents = snapshot.data!;
            return GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio:
                    0.65, // Зурагны эзлэх хувь илүү томоор харагдана
              ),
              itemCount: contents.length,
              itemBuilder: (context, index) {
                LessonContent content = contents[index];
                String tag = 'image_$index';
                Uint8List? imageBytes = content.base64Image != null
                    ? base64Decode(content.base64Image!)
                    : null;

                return GestureDetector(
                  onTap: () {
                    if (imageBytes != null)
                      openFullScreenImage(imageBytes, tag);
                    if (content.base64Audio != null)
                      playAudioFromBase64(content.base64Audio!);
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
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
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (content.description.isNotEmpty)
                                Text(
                                  content.description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              SizedBox(height: 8),
                              if (imageBytes != null)
                                Expanded(
                                  // Зурагны хэмжээ томруулах
                                  child: Hero(
                                    tag: tag,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.memory(
                                        imageBytes,
                                        width: double.infinity,
                                        fit: BoxFit.contain, // Бүтэн харуулна
                                      ),
                                    ),
                                  ),
                                ),
                              if (content.base64Audio != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.pinkAccent,
                                      child: Icon(Icons.volume_up,
                                          size: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
