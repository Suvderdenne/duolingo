import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_flutter/Models/Student.dart';
import 'package:login_flutter/Pages/contain.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<Student> manStudents = [];
  bool isLoad = true;

  void fetch() async {
    try {
      http.Response res = await http.get(Uri.parse("http://127.0.0.1:8000/"));
      var data = jsonDecode(res.body);
      data.forEach((student) {
        Student s = Student(
            id: student['id'],
            stner: student['stner'],
            stovog: student['stovog'],
            date: student['date']);
        manStudents.add(s);
      });
      setState(() {
        isLoad = false;
      });
    } catch (e) {
      print("Өгөгдөл татахад алдаа гарлаа ${e}");
    }
  }

  @override
  void initState() {
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoad
          ? CircularProgressIndicator()
          : Column(
              children: manStudents.map((s) {
              return ConnectData(
                  id: s.id, stner: s.stner, stovog: s.stovog, date: s.date);
            }).toList()),
    );
  }
}
