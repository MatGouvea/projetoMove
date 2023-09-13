// ignore_for_file: prefer_final_fields, use_build_context_synchronously

import 'package:button_animations/button_animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final TextEditingController emailController = TextEditingController();

  Future<void> sendResetEmail(BuildContext context) async {
    String email = emailController.text.trim();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      FloatingSnackBar(
          message: 'E-mail enviado! Verifique o seu e-mail.',
          context: context,
          textStyle: const TextStyle(
            fontSize: 18
          )
        );
    } catch (error) {
      FloatingSnackBar(
          message: 'Ocorreu um erro! Tente novamente mais tarde.',
          context: context,
          textStyle: const TextStyle(
            fontSize: 18
          )
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          //Background
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [secondaryColor, mainColor],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter)),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    elevation: 15,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      padding: const EdgeInsets.only(
                          top: 15, bottom: 15, left: 15, right: 15),
                      child: Column(
                        children: [
                          const Text(
                            'Recuperar senha',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Informe o e-mail cadastrado, você receberá no seu e-mail uma confirmação.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: emailController,
                            key: const ValueKey('email'),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelStyle: const TextStyle(color: mainColor),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: mainColor, width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: mainColor, width: 2),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              labelText: 'E-mail',
                              suffixIcon: const Icon(
                                Icons.email,
                                color: mainColor,
                              ),
                            ),
                            validator: (_email) {
                              final email = _email ?? '';
                              if (email.trim().isEmpty ||
                                  !email.contains('@') ||
                                  email.contains(' ') ||
                                  !email.contains('.com')) {
                                return 'Informe um e-mail válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 50),
                          AnimatedButton(
                            isMultiColor: true,
                            animationCurve: Curves.decelerate,
                            type: null,
                            colors: const [mainColor, secondaryColor],
                            width: 320,
                            borderRadius: 15,
                            blurRadius: 5,
                            duration: 80,
                            onTap: () {
                              sendResetEmail(context);
                            },
                            child: const Text(
                              'Enviar',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnimatedButton(
                            type: null,
                            color: Colors.white,
                            width: 320,
                            borderRadius: 15,
                            borderColor: Colors.grey[50],
                            blurRadius: 5,
                            duration: 100,
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Voltar',
                              style: TextStyle(
                                fontSize: 20,
                                color: mainColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
