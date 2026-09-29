import 'package:flutter/material.dart';
import '../../../../core/localization/app_text.dart';

class FraudAssistantScreen extends StatelessWidget {
  const FraudAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppText.t(context, "Fraud Assistant"),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Center(
        child: Text(
          AppText.t(context, "Fraud Assistant Coming Soon"),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
