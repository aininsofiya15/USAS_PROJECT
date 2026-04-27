import 'package:flutter/material.dart';

class UsasBottomNav extends StatelessWidget {
  const UsasBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(icon: const Icon(Icons.home, size: 40), onPressed: () => Navigator.popUntil(context, (route) => route.isFirst)),
            const Icon(Icons.notifications, size: 40),
            const Icon(Icons.person, size: 40),
          ],
        ),
      ),
    );
  }
}