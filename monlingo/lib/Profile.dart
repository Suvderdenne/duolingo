import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'header_footer.dart';
import 'login.dart'; // Assuming your login page file is named 'login.dart'

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? email;
  String? firstname;
  String? lastname;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      firstname = prefs.getString('firstname');
      lastname = prefs.getString('lastname');
    });
  }

  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()), // Navigate to login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$email',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 10), // Add some spacing between texts
            Text(
              'First Name:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$firstname',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 10), // Add some spacing between texts
            Text(
              'Last Name:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$lastname',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            
              SizedBox(width: 16.0),
            TextButton(
                onPressed: _logout,
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
      
      bottomNavigationBar: Footer(),
    );
  }
}
