import 'package:flutter/material.dart';
import 'package:heartcare/view/app_bar/appbar.dart';

class TreatmentPage extends StatelessWidget {
  const TreatmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: const Center(child: Text('Treatment Recommendations & History')),
    );
  }
}
