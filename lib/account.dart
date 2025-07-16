import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  @override
  const AccountPage({super.key});
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: JohnDoe', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Email: john.doe@example.com', style: TextStyle(fontSize: 18)),
            // Add more account details as needed
          ],
        ),
      ),
    );
  }
}
