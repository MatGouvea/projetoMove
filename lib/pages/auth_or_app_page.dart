// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projeto_move/models/app_user.dart';
import 'package:projeto_move/services/auth_service.dart';
import '../services/auth_firebase_service.dart';
import 'auth_page.dart';
import 'loading_page.dart';
import 'map_page.dart';

class AuthOrAppPage extends StatelessWidget {
  const AuthOrAppPage({super.key});

  Future<void> init(BuildContext context) async {
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(context),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingPage();
          } else {
            return StreamBuilder<AppUser?>(
              stream: AuthService().userChanges,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingPage();
                } else {
                  return snapshot.hasData ? const MapPage() : const AuthPage();
                }
              },
            );
          }
        });
  }
}
