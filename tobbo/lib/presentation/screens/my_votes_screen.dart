import 'package:flutter/material.dart';
import 'package:Tobbo/presentation/screens/activity_screen.dart';

class MyVotesScreen extends StatelessWidget {
  const MyVotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ActivityScreen(initialTab: 1);
  }
}
