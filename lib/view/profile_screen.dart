import 'package:flutter/material.dart';
import 'package:heartcare/view/app_bar/appbar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(child: Text('User Profile Settings')),
    );
  }
}
