import 'package:flutter/material.dart';



class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOuxrvcNMfGLh73uKP1QqYpKoCB0JLXiBMvA&s'), // Replace with actual image URL or asset
            ),
            SizedBox(height: 16),
            Text(
              'David Robinson',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Joined 1 year ago',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 32),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Manage user'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Dark Mode'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {},
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
