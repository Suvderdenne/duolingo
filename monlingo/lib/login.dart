import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart'; // Import your ProfilePage here
import 'signup.dart'; // Import your Signup page here

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void sendJson() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final url = Uri.parse('http://127.0.0.1:8000/login/'); // Correct URL

    final Map<String, dynamic> jsonMap = {
      'username': emailController.text, // Use 'username' instead of 'email'
      'password': passwordController.text,
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final String jsonString = json.encode(jsonMap);
      print('JSON to send: $jsonString');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonString,
      );

      if (response.statusCode == 200) {
        print('Success: ${response.body}');
        final responseData = json.decode(response.body);

        // Save user data to shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('email', responseData['email']);
        prefs.setString('firstname', responseData['full_name']);
        prefs.setString('username', responseData['username']);
        prefs.setString(
            'profile_picture', responseData['profile_picture'] ?? '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User logged in successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Failed with error: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to login.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error sending JSON: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Lottie.asset("register.json",
                  width: 200), // Adjust asset path if needed
              Text(
                "НЭВТРЭХ",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 35),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Нэвтрэх нэр",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Нууц үг",
                  prefixIcon: const Icon(Icons.password_outlined),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: _obscurePassword
                        ? const Icon(Icons.visibility_outlined)
                        : const Icon(Icons.visibility_off_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 50),
              _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: sendJson,
                          child: Text('НЭВТРЭХ'),
                        ),
                        const SizedBox(height: 30),
                        TextButton(
                          onPressed: () {
                            // Navigate to sign up page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Signup()), // Add your Signup page here
                            );
                          },
                          child: Text("БҮРТГҮҮЛЭХ"),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
