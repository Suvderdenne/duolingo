import 'package:flutter/material.dart';
import 'duo.dart';
import 'timelapse.dart';
import 'login.dart';
import 'home.dart';
import 'Profile.dart';
import 'leaderboard.dart';

class Footer extends StatefulWidget {
  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  Map<IconData, bool> _buttonPressed = {
    Icons.person_outlined: false,
    Icons.shop: false,
    Icons.home: false,
    Icons.timelapse: false,
    Icons.leaderboard: false,
    Icons.more_horiz: false,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      color: Colors.transparent, // Set the background to transparent
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [        
          _buildFooterButton(
            context,
            icon: Icons.home,
            destination: HomePage(),
          ),
          _buildFooterButton(
            context,
            icon: Icons.timelapse,
            destination: Duolingo(),
          ),
          _buildFooterButton(
            context,
            icon: Icons.person_outlined,
            destination: ProfilePage(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(BuildContext context,
      {required IconData icon, required Widget destination}) {
    bool isPressed = _buttonPressed[icon] ?? false;

    return Material(
      elevation: 10,
      shape: CircleBorder(),
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        onTapDown: (_) {
          _updateButtonColor(icon, true);
        },
        onTapCancel: () {
          _updateButtonColor(icon, false);
        },
        onTapUp: (_) {
          _updateButtonColor(icon, false);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: isPressed ? 66 : 56,
          height: isPressed ? 66 : 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPressed ? Colors.blue : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: isPressed ? Colors.white : Colors.purple,
          ),
        ),
      ),
    );
  }

  void _updateButtonColor(IconData icon, bool isPressed) {
    setState(() {
      _buttonPressed[icon] = isPressed;
    });
  }
}
