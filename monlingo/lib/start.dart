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
        backgroundColor: Color.fromARGB(255, 235, 178, 197), // Example pink color
      ),
      body: Stack(
        children: [
          Positioned(
            top: 150,
            left: 150,
            child: UnitWidget(title: 'Unit 1', isLocked: true),
          ),
          Positioned(
            top: 250,
            left: 50,
            child: UnitWidget(title: 'Unit 2', isLocked: true),
          ),
          Positioned(
            top: 350,
            left: 150,
            child: UnitWidget(title: 'Unit 3', isLocked: true),
          ),
          Positioned(
            top: 50,
            left: 30,
            child: UnitWidget(title: 'Start', isLocked: false),
          ),
        ],
      ),
    );
  }
}

class UnitWidget extends StatelessWidget {
  final String title;
  final bool isLocked;

  UnitWidget({required this.title, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          isLocked ? Icons.lock : Icons.check_circle,
          size: 50,
          color: isLocked ? Colors.grey : Colors.green,
        ),
        Container(
          decoration: BoxDecoration(
            color: isLocked ? Colors.grey[300] : Colors.yellow,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isLocked ? Colors.grey : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}