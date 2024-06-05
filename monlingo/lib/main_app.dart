import 'package:flutter/material.dart';
import 'package:login_flutter/CreateAccount.dart';

//import 'CreateAccount.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 9, 255, 0),
        ),
      ),
      home: startpage(),
    );
  }
}