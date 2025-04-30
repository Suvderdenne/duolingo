import 'package:flutter/material.dart';
import 'package:login_flutter/CreateAccount.dart';
import 'package:login_flutter/IntroScreens.dart';

//import 'CreateAccount.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key, required bool debugShowCheckedModeBanner});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 145, 255, 142),
        ),
      ),
      home: IntroScreens(),
    );
  }
}