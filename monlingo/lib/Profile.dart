import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'header_footer.dart';
import 'login.dart'; // Assuming your login page file is named 'login.dart'

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

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
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile_image.png'), // Replace with your image path
              ),
            ),
            SizedBox(height: 20),
            _buildTextWithShadow('Email:', email ?? ''),
            _buildTextWithShadow('First Name:', firstname ?? ''),
            _buildTextWithShadow('Last Name:', lastname ?? ''),
          ],
        ),
      ),
      bottomNavigationBar: Footer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logout,
        label: Text(
          'Logout',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        icon: Icon(Icons.logout, color: Colors.white),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTextWithShadow(String label, String text) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border(
              bottom: BorderSide(width: 1.5, color: Colors.grey),),
      ),
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width,),
          Text(
            text,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
