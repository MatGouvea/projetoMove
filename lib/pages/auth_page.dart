import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:projeto_move/models/auth_form_data.dart';
import '../components/auth_form.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = false;

  Future<void> _catchSubmit(AuthFormData formData) async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      if (formData.isLogin) {
        //Login email e senha
        await AuthService().login(formData.email, formData.password);
      } else {
        //Cadastro email e senha
        await AuthService().signup(
          formData.name,
          formData.email,
          formData.password,
        );
      }
    } on FirebaseException catch (error) {
      if (error.code == 'wrong-password') {
        FloatingSnackBar(
          message: 'A senha está incorreta!',
          context: context,
          textStyle: const TextStyle(
            fontSize: 18
          )
        );
      } else if (error.code == 'too-many-requests') {
        FloatingSnackBar(
          message: 'Muitas tentativas. Tente novamente mais tarde.',
          context: context,
          textStyle: const TextStyle(
            fontSize: 18
          )
        );
      } else if (error.code == 'user-not-found') {
        FloatingSnackBar(
          message: 'Essa conta não existe ou foi deletada.',
          context: context,
          textStyle: const TextStyle(
            fontSize: 18
          )
        );
      } else if (error.code == 'email-already-in-use') {
        FloatingSnackBar(
          message: 'Esse endereço de e-mail já está sendo utilizado.',
          context: context,
          textStyle: const TextStyle(
            fontSize: 18
          )
        );
      } else if (error.code == 'network-request-failed') {
        FloatingSnackBar(
          message: 'Conexão com a internet indisponível.',
          context: context,
          textStyle: const TextStyle(
            fontSize: 18
          )
        );
      } else {
        FloatingSnackBar(
          message: 'Um erro inesperado ocorreu.',
          context: context,
          textStyle: const TextStyle(
            fontSize: 18
          )
        );
      }
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
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
                gradient: LinearGradient(colors: [
              secondaryColor,
              mainColor
            ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    filterQuality: FilterQuality.high,
                    height: 180,
                    width: 180,
                  ),
                  AuthForm(
                    onSubmit: _catchSubmit,
                    loadingState: _isLoading,
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
