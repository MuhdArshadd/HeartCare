import 'package:flutter/material.dart';
import 'package:heartcare/view/app_bar/appbar.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: const Center(child: Text('Add New Symptom or Treatment Log')),
    );
  }
}
