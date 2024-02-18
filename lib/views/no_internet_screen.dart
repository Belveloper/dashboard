import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.network_wifi,
            size: 30,
          ),
          AutoSizeText(
            'Veuillez vous assurer que votre appareil est correctement connecté à Internet.',
            textAlign: TextAlign.center,
            textScaleFactor: 1,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
