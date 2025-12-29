import 'package:flutter/material.dart';
import 'package:prepify/components/custom_app_bar.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Search'),
      body: const Center(
        child: Text('Search Page'),
      ),
    );
  }
}