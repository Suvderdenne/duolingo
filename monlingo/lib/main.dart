import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:login_flutter/CreateAccount.dart';

import 'main_app.dart';
import 'IntroScreens.dart';

void main() async {
  await _initHive();
  runApp(const MainApp());
  
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  await Hive.openBox("login");
  await Hive.openBox("accounts");
}
