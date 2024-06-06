import 'package:flutter/material.dart';
import 'duo.dart';
import 'timelapse.dart';
import 'login.dart';
class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFooterButton(
            context,
            icon: Icons.home,
            destination: Login(),
          ),
          _buildFooterButton(
            context,
            icon: Icons.shop,
            destination: Duo(),
          ),
          _buildFooterButton(
            context,
            icon: Icons.person_outlined,
            destination: Login(),
          ),
          _buildFooterButton(
            context,
            icon: Icons.timelapse,
            destination: Duolingo(),
          ),
          _buildFooterButton(
            context,
            icon: Icons.more_horiz,
            destination: Login(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(BuildContext context, {required IconData icon, required Widget destination}) {
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
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
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
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
