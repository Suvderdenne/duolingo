import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'header_footer.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? email;
  String? fullName;
  int? score;
  String? profilePicture;
  final imageUrl =
      'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.vecteezy.com%2Ffree-vector%2Fprofile-icon&psig=AOvVaw2sMKLjRQDDXBwnoi-hggGK&ust=1745910650734000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCPDlrJqW-owDFQAAAAAdAAAAABAE'; // Default placeholder image

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      email = prefs.getString('email');
      fullName = prefs.getString('full_name');
      score = prefs.getInt('score');
      profilePicture = prefs.getString('profile_picture') ??
          imageUrl; // Fallback to default image if null
    });
  }

  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.green],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Center(
              child: CircleAvatar(
                radius: 100,
                backgroundColor: const Color.fromARGB(
                    255, 99, 104, 109), // Set background color if needed
                child: Icon(
                  Icons.person, // Profile icon
                  size: 80, // Icon size
                  color: Colors.white, // Icon color
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildTextWithShadow('Username:', username ?? 'Not Available'),
            _buildTextWithShadow('Email:', email ?? 'Not Available'),
            _buildTextWithShadow('Full Name:', fullName ?? 'Not Available'),
            _buildTextWithShadow(
                'Score:', score?.toString() ?? 'Not Available'),
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
          bottom: BorderSide(width: 3, color: Colors.white),
        ),
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
          SizedBox(
            width: MediaQuery.of(context).size.width,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 16.0,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ],
      ),
    );
  }
}
