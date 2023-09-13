import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromRGBO(75, 6, 139, 1),
          Color.fromRGBO(0, 115, 255, 1),
        ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              filterQuality: FilterQuality.high,
              height: 180,
              width: 180,
            ),
            LoadingAnimationWidget.prograssiveDots(
              color: Colors.white,
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}
