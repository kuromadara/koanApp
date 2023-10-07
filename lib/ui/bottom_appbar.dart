import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomAppBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      // shape: const CircularNotchedRectangle(),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () => onTap(0),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => onTap(1),
          ),
          // Add more IconButton widgets as needed
        ],
      ),
    );
  }
}
