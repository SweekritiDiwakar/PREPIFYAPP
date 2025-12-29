import 'package:flutter/material.dart';
import 'package:prepify/components/custom_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      body: const Center(
        child: Text('Profile Page'),
      ),
    );
  }
}