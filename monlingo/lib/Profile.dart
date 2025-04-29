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
  final defaultImage =
      'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.vecteezy.com%2Ffree-vector%2Fprofile-icon&psig=AOvVaw2sMKLjRQDDXBwnoi-hggGK&ust=1745910650734000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCPDlrJqW-owDFQAAAAAdAAAAABAE'; // Default placeholder image
  List<String> iconOptions = [
    'data:image/jpeg;base64,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', // Example image URLs
    'data:image/jpeg;base64,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',
    'https://static.vecteezy.com/system/resources/thumbnails/002/002/403/small/man-with-beard-avatar-character-isolated-icon-free-vector.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR6zpeYqtKpIWB_q0SY3NrtlQa9CEkvUtl6eA&s',
  ];

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
      profilePicture = prefs.getString('profile_picture') ?? defaultImage;
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

  _chooseProfilePicture() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Profile Picture'),
        content: SingleChildScrollView(
          child: Column(
            children: iconOptions.map((imageUrl) {
              return GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('profile_picture', imageUrl); // Save the selected image
                  setState(() {
                    profilePicture = imageUrl; // Update the UI with the selected image
                  });
                  Navigator.pop(context); // Close the dialog
                },
                child: Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
          ),
        ),
      ),
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
            colors: [Colors.blue, const Color.fromARGB(255, 255, 255, 255)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Center(
              child: GestureDetector(
                onTap: _chooseProfilePicture, // Allow the user to select an image
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: const Color.fromARGB(255, 99, 104, 109),
                  backgroundImage: NetworkImage(profilePicture!),
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildTextWithShadow('Username:', username ?? 'Not Available'),
            _buildTextWithShadow('Email:', email ?? 'Not Available'),
            _buildTextWithShadow('Full Name:', fullName ?? 'Not Available'),
            _buildTextWithShadow('Score:', score?.toString() ?? 'Not Available'),
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
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            text,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
