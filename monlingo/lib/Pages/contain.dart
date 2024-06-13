import 'package:flutter/material.dart';

class ConnectData extends StatelessWidget {
  final int id;
  final String stner;
  final String stovog;
  final String date;
  const ConnectData(
      {super.key,
      required this.id,
      required this.stner,
      required this.stovog,
      required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(children: [
        Text(
          stner,
          style: TextStyle(
              color: Colors.lightBlue,
              fontSize: 12,
              fontWeight: FontWeight.bold),
        ),
        Text(
          stovog,
          style: TextStyle(color: Colors.lightBlueAccent, fontSize: 11),
        ),
        Text(
          date,
          style: TextStyle(color: Colors.grey, fontSize: 9),
        )
      ]),
    );
  }
}
