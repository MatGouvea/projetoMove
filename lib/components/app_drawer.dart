// ignore_for_file: unnecessary_null_comparison, prefer_if_null_operators

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../pages/settings_page.dart';
import '../services/auth_firebase_service.dart';
import '../utils/app_routes.dart';
import '../utils/constants.dart';
import 'image_getter.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _logout = AuthFirebaseService();

  final User? user = FirebaseAuth.instance.currentUser;

  FlutterTts flutterTts = FlutterTts();

  void speak(String text, bool isTts) async {
    if (isTts) {
      await flutterTts.setLanguage('pt-BR');
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsPage>(context);
    final isDarkMode = settings.isDarkMode;
    final isTts = settings.isTts;
    final fontSize = settings.fontSize;

    return Drawer(
      backgroundColor: isDarkMode ? darkMainColor : null,
      width: 260,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(15), bottomRight: Radius.circular(15))),
      child: Column(
        children: [
          //Bloco de usuário
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 50, bottom: 20),
                width: double.infinity,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color.fromRGBO(75, 6, 139, 1),
                      Color.fromRGBO(0, 115, 255, 1),
                    ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                    color: mainColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    )),
                child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null ||
                          snapshot.data!.data() == null) {
                        return LoadingAnimationWidget.prograssiveDots(
                          color: Colors.white,
                          size: 50,
                        );
                      }

                      Map<String, dynamic> userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      bool isWheelchair = userData['wheelchair'] ?? false;
                      bool isBlind = userData['blind'] ?? false;
                      bool isDeaf = userData['deaf'] ?? false;

                      return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.displayName)
                              .get(),
                          builder: (ctx, snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: CircleAvatar(
                                      child: ClipOval(
                                          child:
                                              ImageGetter(userId: user!.uid)),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    user!.displayName!,
                                    style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Visibility(
                                        visible: isWheelchair,
                                        child: CircleAvatar(
                                          backgroundColor: isDarkMode
                                              ? darkMainColor
                                              : Colors.white,
                                          child: Icon(
                                            Icons.accessible_forward,
                                            color: isDarkMode
                                                ? Colors.white
                                                : mainColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Visibility(
                                        visible: isBlind,
                                        child: CircleAvatar(
                                          backgroundColor: isDarkMode
                                              ? darkMainColor
                                              : Colors.white,
                                          child: Icon(
                                            Icons.blind,
                                            color: isDarkMode
                                                ? Colors.white
                                                : mainColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Visibility(
                                        visible: isDeaf,
                                        child: CircleAvatar(
                                          backgroundColor: isDarkMode
                                              ? darkMainColor
                                              : Colors.white,
                                          child: Icon(
                                            Icons.hearing_disabled,
                                            color: isDarkMode
                                                ? Colors.white
                                                : mainColor,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: CircleAvatar(
                                      child: ClipOval(
                                          child: Image.asset(
                                        'assets/images/avatar.png',
                                      )),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  LoadingAnimationWidget.prograssiveDots(
                                    color: Colors.white,
                                    size: 30,
                                  )
                                ],
                              );
                            }
                          });
                    }),
              ),
              const SizedBox(height: 10),
              // Itens do drawer
              ListTile(
                key: UniqueKey(),
                leading: const Icon(
                  Icons.accessibility,
                  size: 40,
                  color: mainColor,
                ),
                title: Text(
                  'Ajustes',
                  style: TextStyle(
                      fontSize: fontSize == 0 ? 20 : 25,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : null),
                ),
                subtitle: Text('Conta e acessibilidade',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : null,
                      fontSize: fontSize == 0 ? null : 20,
                    )),
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.settingsPage);
                  speak(
                      "Entrando em configurações, primeira seção: ajustes de conta. Segunda seção: opções de acessibilidade",
                      isTts);
                },
              ),
              Divider(color: isDarkMode ? Colors.grey[900] : null),
              ListTile(
                key: UniqueKey(),
                leading: const Icon(
                  Icons.star,
                  size: 40,
                  color: mainColor,
                ),
                title: Text(
                  'Locais salvos',
                  style: TextStyle(
                      fontSize: fontSize == 0 ? 20 : 25,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : null),
                ),
                subtitle: Text('Locais salvos por você',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : null,
                      fontSize: fontSize == 0 ? null : 20,
                    )),
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.favoritePage);
                  speak("Entrando em locais salvos", isTts);
                },
              ),
              Divider(color: isDarkMode ? Colors.grey[900] : null),
              ListTile(
                key: UniqueKey(),
                leading: const Icon(
                  Icons.history,
                  size: 40,
                  color: mainColor,
                ),
                title: Text(
                  'Locais recentes',
                  style: TextStyle(
                      fontSize: fontSize == 0 ? 20 : 25,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : null),
                ),
                subtitle: Text('Últimos locais vistos',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : null,
                      fontSize: fontSize == 0 ? null : 20,
                    )),
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.recentPlacesPage);
                  speak("Entrando em locais recentes", isTts);
                },
              ),
              Divider(color: isDarkMode ? Colors.grey[900] : null),
              ListTile(
                key: UniqueKey(),
                leading: const Icon(
                  Icons.logout,
                  size: 40,
                  color: mainColor,
                ),
                title: Text(
                  'Sair',
                  style: TextStyle(
                      fontSize: fontSize == 0 ? 20 : 25,
                      color: isDarkMode ? Colors.white : null,
                      fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Voltar a tela de login',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : null,
                      fontSize: fontSize == 0 ? null : 20,
                    )),
                onTap: () {
                  speak("Saindo da conta atual", isTts);
                  _logout.logout();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
