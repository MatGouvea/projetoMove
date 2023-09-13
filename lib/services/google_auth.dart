// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          FloatingSnackBar(
              message: 'Essa conta já existe com outras credenciais.',
              context: context,
              textStyle: const TextStyle(fontSize: 18));
        } else if (e.code == 'invalid-credential') {
          FloatingSnackBar(
              message: 'Credenciais inválidas.',
              context: context,
              textStyle: const TextStyle(fontSize: 18));
        } 
      } catch (e) {
        FloatingSnackBar(
            message: 'Um erro inesperado ocorreu.',
            context: context,
            textStyle: const TextStyle(fontSize: 18));
      }
    }
    return user;
  }

  Future<void> signOut({required BuildContext context}) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      FloatingSnackBar(
            message: 'Um erro inesperado ocorreu.',
            context: context,
            textStyle: const TextStyle(fontSize: 18));
    }
  }
}
