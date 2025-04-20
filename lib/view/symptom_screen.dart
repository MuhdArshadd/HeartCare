import 'package:flutter/material.dart';
import 'package:heartcare/view/app_bar/appbar.dart';

class SymptomPage extends StatelessWidget {
  const SymptomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(child: Text('Symptom Log and History')),
    );
  }
}
