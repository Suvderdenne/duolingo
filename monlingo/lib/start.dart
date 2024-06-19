import 'package:flutter/material.dart';


class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 245, 222, 229),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              '../assets/start/image.png',
              fit: BoxFit.cover,
            ),
          ),
          // Overlaying UnitWidgets
          Positioned(
            top: 370,
            left: 30,
            child: UnitWidget(imagePath: '../assets/start/1.png', title: '1', stars: 3, isLocked: false),
          ),
          Positioned(
            top: 280,
            left: 110,
            child: UnitWidget(imagePath: '../assets/start/1.png', title: '2', stars: 1, isLocked: false),
          ),
          Positioned(
            top: 210,
            left: 200,
            child: UnitWidget(imagePath: '../assets/start/1.png', title: '3', stars: 2, isLocked: false),
          ),
          Positioned(
            top: 150,
            left: 280,
            child: UnitWidget(imagePath: '../assets/start/1.png', title: '4', stars: 3, isLocked: false),
          ),
          Positioned(
            top: 140,
            left: 380,
            child: UnitWidget(imagePath: '../assets/start/1.png', title: '5', stars: 2, isLocked: false),
          ),
          Positioned(
            top: 90,
            left: 470,
            child: UnitWidget(imagePath: '../assets/start/1.png', title: '6', stars: 0, isLocked: true),
          ),
          Positioned(
            top: 20,
            left: 560,
            child: UnitWidget(imagePath: '../assets/start/1.png', title: '7', stars: 0, isLocked: true),
          ),
        ],
      ),
    );
  }
}

class UnitWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final int stars;
  final bool isLocked;

  const UnitWidget({
    required this.imagePath,
    required this.title,
    required this.stars,
    required this.isLocked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        if (isLocked)
          Icon(
            Icons.lock,
            size: 50,
            color: Colors.grey,
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              stars,
              (index) => Icon(
                Icons.star,
                size: 20,
                color: Colors.yellow,
              ),
            ),
          ),
        SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: isLocked ? Colors.grey[300] : Colors.orange,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            imagePath,
            width: 50,
            height: 50,
          ),
        ),
      ],
    );
  }
}