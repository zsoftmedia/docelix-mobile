import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: TextStyle(fontSize: rs.sp(20)),
        ),
      ),
      body: ResponsivePage(
        padding: EdgeInsets.all(rs.s(16)),
        child: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: Icon(Icons.search, size: rs.s(22)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rs.s(12)),
            ),
          ),
        ),
      ),
    );
  }
}
