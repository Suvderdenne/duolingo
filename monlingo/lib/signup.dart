import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  Future<void> registerUser() async {
    final url = Uri.parse('http://127.0.0.1:8000/register/');

    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> data = {
      'username': usernameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text,
      'full_name': usernameController.text.trim(), // Optional: add separate controller for full name
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Амжилттай бүртгэгдлээ!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Дахин Login хуудас руу буцах
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Алдаа: ${responseData.toString()}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Сүлжээний алдаа: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 80),
              Lottie.asset("register.json", width: 200), // Replace with actual asset path
              Text("Бүртгүүлэх", style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 10),
              Text("Шинэ бүртгэл үүсгэх", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 30),

              // Username
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Хэрэглэгчийн нэр",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Хэрэглэгчийн нэр оруулна уу' : null,
              ),
              const SizedBox(height: 10),

              // Email
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Имэйл",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) =>
                    value == null || !value.contains('@') ? 'Зөв имэйл хаяг оруулна уу' : null,
              ),
              const SizedBox(height: 10),

              // Password
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Нууц үг",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) =>
                    value == null || value.length < 6 ? 'Нууц үг хамгийн багадаа 6 тэмдэгт байх ёстой' : null,
              ),
              const SizedBox(height: 10),

              // Repeat Password
              TextFormField(
                controller: repeatPasswordController,
                obscureText: _obscureRepeatPassword,
                decoration: InputDecoration(
                  labelText: "Нууц үгээ давтана уу",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureRepeatPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureRepeatPassword = !_obscureRepeatPassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) =>
                    value != passwordController.text ? 'Нууц үг таарахгүй байна' : null,
              ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: registerUser,
                child: const Text('Бүртгүүлэх', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Бүртгэлтэй хэрэглэгч үү?"),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Нэвтрэх"),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
