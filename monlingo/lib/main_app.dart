import 'package:flutter/material.dart';
import 'package:login_flutter/CreateAccount.dart';
import 'package:login_flutter/IntroScreens.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 👈 Энэ нь Debug бичгийг арилгана
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 145, 255, 142),
        ),
      ),
      home: IntroScreens(),
    );
  }
}
