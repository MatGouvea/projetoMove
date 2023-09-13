// ignore_for_file: sized_box_for_whitespace, no_leading_underscores_for_local_identifiers

import 'package:button_animations/button_animations.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:projeto_move/utils/app_routes.dart';
import '../models/auth_form_data.dart';
import '../services/google_auth.dart';
import '../utils/constants.dart';

class AuthForm extends StatefulWidget {
  final void Function(AuthFormData) onSubmit;
  final bool loadingState;

  const AuthForm({
    required this.loadingState,
    required this.onSubmit,
    super.key,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {

  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formData = AuthFormData();
  final _googleAuth = GoogleAuth();

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    widget.onSubmit(_formData);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 20, right: 20),
      elevation: 15,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
        child: Container(
          padding:
              const EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  _formData.isLogin ? 'Efetuar Login' : 'Efetuar Cadastro',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                if (_formData.isSignup) const SizedBox(height: 20),
                // FormField Nome de usuário
                if (_formData.isSignup)
                  TextFormField(
                    onChanged: (name) => _formData.name = name,
                    key: const ValueKey('name'),
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: mainColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: mainColor, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: mainColor, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      labelText: 'Nome de usuário ',
                      suffixIcon: const Icon(
                        Icons.person_rounded,
                        color: mainColor,
                      ),
                    ),
                    validator: _formData.isLogin
                        ? null
                        : (_name) {
                            final name = _name ?? '';
                            if (name.length > 20) {
                              return 'O nome não deve conter mais que 20 caracteres.';
                            } else if (name.isEmpty) {
                              return 'Informe o nome desejado.';
                            } else if (name.length < 3) {
                              return 'O nome deve conter ao menos 3 caracteres.';
                            }
                            return null;
                          },
                  ),
                const SizedBox(height: 20),
                // FormField email
                TextFormField(
                  onChanged: (email) => _formData.email = email,
                  key: const ValueKey('email'),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: mainColor),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: mainColor, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: mainColor, width: 2),
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
                const SizedBox(height: 20),
                // FormField senha
                TextFormField(
                  onChanged: (password) => _formData.password = password,
                  key: const ValueKey('password'),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: mainColor),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: mainColor, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: mainColor, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: const Icon(
                      Icons.lock,
                      color: mainColor,
                    ),
                    labelText: 'Senha',
                  ),
                  controller: _passwordController,
                  validator: (_password) {
                    final password = _password ?? '';
                    if (password.length < 8 && _formData.isSignup) {
                      return 'A senha deve conter ao menos 8 caracteres.';
                    } else if (password.isEmpty) {
                      return 'Informe a senha.';
                    }
                    return null;
                  },
                ),
                if (_formData.isSignup) const SizedBox(height: 20),
                // FormField confirmar senha
                if (_formData.isSignup)
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: mainColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: mainColor, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: mainColor, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      labelText: 'Confirmar senha',
                      suffixIcon: const Icon(
                        Icons.lock,
                        color: mainColor,
                      ),
                    ),
                    validator: _formData.isLogin
                        ? null
                        : (_password) {
                            final password = _password ?? '';
                            if (password != _passwordController.text) {
                              return 'Senhas informadas não conferem.';
                            }
                            return null;
                          },
                  ),
                const SizedBox(height: 10),
                //Esqueci minha senha
                if (_formData.isLogin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.forgotPasswordPage);
                        },
                        child: const Text(
                          'Esqueci minha senha',
                          style: TextStyle(
                            fontSize: 20,
                            color: mainColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 15),
                // Botão Entrar/Cadastrar
                widget.loadingState
                    ? LoadingAnimationWidget.prograssiveDots(
                        color: mainColor,
                        size: 30,
                      )
                    : AnimatedButton(
                        isMultiColor: true,
                        animationCurve: Curves.decelerate,
                        type: null,
                        colors: const [
                          mainColor,
                          secondaryColor
                        ],
                        width: 320,
                        borderRadius: 15,
                        blurRadius: 5,
                        duration: 80,
                        onTap: _submit,
                        child: Text(
                          _formData.isLogin ? 'Entrar' : 'Criar nova conta',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                const SizedBox(height: 20),
                // Trocar tela de cadastro/login
                AnimatedButton(
                  type: null,
                  color: Colors.white,
                  width: 320,
                  borderRadius: 15,
                  borderColor: Colors.grey[50],
                  blurRadius: 5,
                  duration: 100,
                  onTap: () {
                    setState(() {
                      _formData.toggleAuthMode();
                    });
                  },
                  child: Text(
                    _formData.isLogin ? 'Criar nova conta' : 'Voltar',
                    style: const TextStyle(
                      fontSize: 20,
                      color: mainColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_formData.isLogin) const Divider(),
                // Autenticação com o Google
                if (_formData.isLogin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Conectar com',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                      AnimatedButton(
                        animationCurve: Curves.decelerate,
                        borderRadius: 50,
                        duration: 80,
                        blurRadius: 5,
                        borderColor: Colors.grey[50],
                        width: 60,
                        type: null,
                        color: Colors.white,
                        onTap: () {
                          _googleAuth.signInWithGoogle(context: context);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          child: Image.asset(
                            'assets/images/google_logo.png',
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
