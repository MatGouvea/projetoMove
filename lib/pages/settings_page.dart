// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:projeto_move/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../components/image_getter.dart';
import '../components/map_controller_holder.dart';
import '../components/map_style_holder.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SettingsPage extends StatelessWidget with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isDarkMode = false;
  bool _isZoomHide = false;
  bool _isTts = false;

  double _fontSize = 0;

  bool _isWheelchair = false;
  bool _isBlind = false;
  bool _isDeaf = false;

  bool get isDarkMode => _isDarkMode;
  bool get isZoomHide => _isZoomHide;
  bool get isWheelchair => _isWheelchair;
  bool get isBlind => _isBlind;
  bool get isDeaf => _isDeaf;
  bool get isTts => _isTts;
  double get fontSize => _fontSize;

  TextEditingController nameEditController = TextEditingController();
  TextEditingController passwordEditController = TextEditingController();

  FlutterTts flutterTts = FlutterTts();

  final User? user = FirebaseAuth.instance.currentUser;

  void toggleWheelchair(bool newValue) {
    _isWheelchair = newValue;
    notifyListeners();
  }

  void toggleBlind(bool newValue) {
    _isBlind = newValue;
    notifyListeners();
  }

  void toggleDeaf(bool newValue) {
    _isDeaf = newValue;
    notifyListeners();
  }

  toggleFontSize(double value) {
    _prefs.setDouble('fontSize', value);
    _fontSize = value;
    notifyListeners();
  }

  toggleZoomHide(bool value) {
    _prefs.setBool('isZoomHide', value);
    _isZoomHide = value;
    notifyListeners();
  }

  toggleTts(bool value) {
    _prefs.setBool('isTts', value);
    _isTts = value;
    notifyListeners();
  }

  toggleDarkMode(bool value) {
    _prefs.setBool('isDarkMode', value);
    _isDarkMode = value;
    MapControllerHolder.mapController
        .setMapStyle(isDarkMode ? darkMapStyle : null);
    notifyListeners();
  }

  SettingsPage({super.key}) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _isZoomHide = _prefs.getBool('isZoomHide') ?? false;
    _isTts = _prefs.getBool('isTts') ?? true;
    notifyListeners();
  }

  Future<XFile?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<String> uploadImage(XFile imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
        user!.displayName.toString();
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('images')
        .child(fileName);

    firebase_storage.UploadTask uploadTask = ref.putFile(File(imageFile.path));
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future<void> updateUserImage(String userId, String imageUrl) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await userRef.update({
      'image': imageUrl,
    });
  }

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
    nameEditController.text = user!.displayName!;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return Consumer<SettingsPage>(
      builder: (context, settings, _) {
        final isDarkMode = settings.isDarkMode;
        final isTts = settings.isTts;
        final fontSize = settings.fontSize;

        Future<void> updateWheelchairDocument(bool isWheelchair) async {
          final FirebaseFirestore firestore = FirebaseFirestore.instance;
          final userRef = firestore.collection('users').doc(user!.uid);

          await userRef.update({
            'wheelchair': isWheelchair,
          });
        }

        Future<void> updateBlindDocument(bool isBlind) async {
          final FirebaseFirestore firestore = FirebaseFirestore.instance;
          final userRef = firestore.collection('users').doc(user!.uid);

          await userRef.update({
            'blind': isBlind,
          });
        }

        Future<void> updateDeafDocument(bool isDeaf) async {
          final FirebaseFirestore firestore = FirebaseFirestore.instance;
          final userRef = firestore.collection('users').doc(user!.uid);

          await userRef.update({
            'deaf': isDeaf,
          });
        }

        return Scaffold(
          backgroundColor: isDarkMode ? darkMainColor : null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  const SizedBox(width: 15),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      speak("Voltando ao mapa", isTts);
                    },
                    icon: const Icon(
                      Icons.navigate_before,
                      color: mainColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Ajustes',
                        style: TextStyle(
                            fontSize: fontSize == 0 ? 20 : 25,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : null),
                      ),
                      const SizedBox(height: 10)
                    ],
                  )
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        '      Conta',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : null,
                          fontSize: fontSize == 0 ? null : 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          color:
                              isDarkMode ? secDarkMainColor : Colors.grey[200],
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 10),
                            child: Column(
                              children: [
                                Text(
                                  'Imagem de perfil',
                                  style: TextStyle(
                                      fontSize: fontSize == 0 ? 20 : 25,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? Colors.white : null),
                                ),
                                const SizedBox(height: 30),
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: CircleAvatar(
                                    child: ClipOval(
                                        child: ImageGetter(userId: user!.uid)),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: fontSize == 0 ? 120 : 130,
                                  child: Flexible(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: mainColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15))),
                                      onPressed: () async {
                                        XFile? image = await pickImage();
                                        if (image != null) {
                                          String imageUrl =
                                              await uploadImage(image);
                                          await updateUserImage(
                                              user!.uid, imageUrl);
                                        }
                                        speak("Alterando imagem de perfil",
                                            isTts);
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            'Alterar',
                                            style: TextStyle(
                                                fontSize:
                                                    fontSize == 0 ? 20 : 25,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(width: 5),
                                          const Icon(Icons.edit),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '   Nome de usuário',
                                      style: TextStyle(
                                          fontSize: fontSize == 0 ? 20 : 25,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isDarkMode ? Colors.white : null),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 15),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: isDarkMode
                                            ? Colors.grey[700]
                                            : Colors.white,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: TextField(
                                        readOnly: true,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: isDarkMode
                                                ? Colors.white
                                                : null),
                                        controller: nameEditController,
                                        decoration: const InputDecoration(
                                            border: InputBorder.none),
                                      ),
                                    ),
                                    Positioned(
                                      right: 15,
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.edit,
                                          color: isDarkMode
                                              ? Colors.white
                                              : mainColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '   Possui alguma deficiência?',
                                      style: TextStyle(
                                          fontSize: fontSize == 0 ? 20 : 25,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isDarkMode ? Colors.white : null),
                                    ),
                                  ],
                                ),
                                //Switch físico
                                //
                                const SizedBox(height: 15),
                                const Divider(),
                                StreamBuilder<DocumentSnapshot>(
                                    stream: _firestore
                                        .collection('users')
                                        .doc(user!.uid)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.data == null ||
                                          snapshot.data!.data() == null) {
                                        return LoadingAnimationWidget
                                            .prograssiveDots(
                                          color: Colors.white,
                                          size: 50,
                                        );
                                      }

                                      Map<String, dynamic> userData =
                                          snapshot.data!.data()
                                              as Map<String, dynamic>;
                                      bool isWheelchair =
                                          userData['wheelchair'] ?? false;
                                      bool isBlind = userData['blind'] ?? false;
                                      bool isDeaf = userData['deaf'] ?? false;

                                      return Column(
                                        children: [
                                          SwitchListTile(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15))),
                                            tileColor: isDarkMode
                                                ? secDarkMainColor
                                                : Colors.grey[200],
                                            activeColor: mainColor,
                                            title: Row(
                                              children: [
                                                Icon(
                                                  Icons.accessible_forward,
                                                  color: isDarkMode
                                                      ? Colors.grey[200]
                                                      : Colors.grey[800],
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'Deficiência física',
                                                  style: TextStyle(
                                                    fontSize:
                                                        fontSize == 0 ? 20 : 25,
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            value: isWheelchair,
                                            onChanged: (newValue) {
                                              settings
                                                  .toggleWheelchair(newValue);
                                              updateWheelchairDocument(
                                                  newValue);
                                              speak(
                                                  newValue
                                                      ? "Você possui deficiência física"
                                                      : "Você não possui deficiência física",
                                                  isTts);
                                            },
                                          ),
                                          //Switch visual
                                          //
                                          SwitchListTile(
                                            tileColor: isDarkMode
                                                ? secDarkMainColor
                                                : Colors.grey[200],
                                            activeColor: mainColor,
                                            title: Row(
                                              children: [
                                                Icon(
                                                  Icons.blind,
                                                  color: isDarkMode
                                                      ? Colors.grey[200]
                                                      : Colors.grey[800],
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'Deficiência visual',
                                                  style: TextStyle(
                                                    fontSize:
                                                        fontSize == 0 ? 20 : 25,
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            value: isBlind,
                                            onChanged: (newValue) {
                                              settings.toggleBlind(newValue);
                                              updateBlindDocument(newValue);
                                              speak(
                                                  newValue
                                                      ? "Você possui deficiência visual"
                                                      : "Você não possui deficiência visual",
                                                  isTts);
                                            },
                                          ),
                                          //Switch auditivo
                                          //
                                          SwitchListTile(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(15),
                                                    bottomRight:
                                                        Radius.circular(15))),
                                            tileColor: isDarkMode
                                                ? secDarkMainColor
                                                : Colors.grey[200],
                                            activeColor: mainColor,
                                            title: Row(
                                              children: [
                                                Icon(
                                                  Icons.hearing_disabled,
                                                  color: isDarkMode
                                                      ? Colors.grey[200]
                                                      : Colors.grey[800],
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'Deficiência auditiva',
                                                  style: TextStyle(
                                                    fontSize:
                                                        fontSize == 0 ? 20 : 25,
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            value: isDeaf,
                                            onChanged: (newValue) {
                                              settings.toggleDeaf(newValue);
                                              updateDeafDocument(newValue);
                                              speak(
                                                  newValue
                                                      ? "Você possui deficiência auditiva"
                                                      : "Você não possui deficiência auditiva",
                                                  isTts);
                                            },
                                          ),
                                        ],
                                      );
                                    }),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        '      Acessibilidade',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : null,
                          fontSize: fontSize == 0 ? null : 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      //Switch modo escuro
                      //
                      SwitchListTile(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15))),
                          tileColor:
                              isDarkMode ? secDarkMainColor : Colors.grey[200],
                          activeColor: mainColor,
                          title: Row(
                            children: [
                              Icon(
                                Icons.dark_mode,
                                color: isDarkMode
                                    ? Colors.grey[200]
                                    : Colors.grey[800],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Modo Escuro',
                                style: TextStyle(
                                  fontSize: fontSize == 0 ? 20 : 25,
                                  color: isDarkMode ? Colors.white : null,
                                ),
                              ),
                            ],
                          ),
                          value: settings.isDarkMode,
                          onChanged: (value) {
                            settings.toggleDarkMode(value);
                            speak(
                                value
                                    ? "Modo escuro, ativado"
                                    : "Modo escuro, desativado",
                                isTts);
                          }),
                      // Switch talkback
                      //
                      SwitchListTile(
                          tileColor:
                              isDarkMode ? secDarkMainColor : Colors.grey[200],
                          activeColor: mainColor,
                          title: Row(
                            children: [
                              Icon(
                                Icons.mic,
                                color: isDarkMode
                                    ? Colors.grey[200]
                                    : Colors.grey[800],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Talkback',
                                style: TextStyle(
                                  fontSize: fontSize == 0 ? 20 : 25,
                                  color: isDarkMode ? Colors.white : null,
                                ),
                              ),
                            ],
                          ),
                          value: settings.isTts,
                          onChanged: (value) {
                            settings.toggleTts(value);
                            speak(
                                value
                                    ? "Talkback, ativado"
                                    : "Talkback, desativado",
                                isTts);
                          }),
                      //Slider tamanho da fonte
                      //
                      Container(
                        color: isDarkMode ? secDarkMainColor : Colors.grey[200],
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                const SizedBox(width: 15),
                                Icon(
                                  Icons.text_fields,
                                  color: isDarkMode
                                      ? Colors.grey[200]
                                      : Colors.grey[800],
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Tamanho da fonte',
                                  style: TextStyle(
                                    fontSize: fontSize == 0 ? 20 : 25,
                                    color: isDarkMode ? Colors.white : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Slider(
                                min: 0,
                                max: 1,
                                value: settings.fontSize,
                                thumbColor: mainColor,
                                onChanged: (value) {
                                  settings.toggleFontSize(value);
                                  speak(
                                      value == 1
                                          ? "Tamanho da fonte alterado para, grande"
                                          : "Tamanho da fonte alterado para, normal",
                                      isTts);
                                }),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Normal',
                                    style: TextStyle(
                                      fontSize: fontSize == 0 ? 18 : 23,
                                      color: isDarkMode ? Colors.white : null,
                                    ),
                                  ),
                                  Text(
                                    'Grande',
                                    style: TextStyle(
                                      fontSize: fontSize == 0 ? 18 : 23,
                                      color: isDarkMode ? Colors.white : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                      //Switch botões de zoom
                      //
                      SwitchListTile(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15))),
                          tileColor:
                              isDarkMode ? secDarkMainColor : Colors.grey[200],
                          activeColor: mainColor,
                          title: Row(
                            children: [
                              Icon(
                                Icons.zoom_in,
                                color: isDarkMode
                                    ? Colors.grey[200]
                                    : Colors.grey[800],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Esconder botões de zoom',
                                style: TextStyle(
                                  fontSize: fontSize == 0 ? 20 : 25,
                                  color: isDarkMode ? Colors.white : null,
                                ),
                              ),
                            ],
                          ),
                          value: settings.isZoomHide,
                          onChanged: (value) {
                            settings.toggleZoomHide(value);
                            speak(
                                value
                                    ? "Botões de zoom estão escondidos"
                                    : "Botões de zoom estão sendo mostrados",
                                isTts);
                          }),
                      const SizedBox(height: 50),
                      Center(
                        child: SizedBox(
                          height: 80,
                          width: 100,
                          child: Image.asset(isDarkMode
                              ? 'assets/images/logo.png'
                              : 'assets/images/logo_color.png'),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Projeto Move!\nSoftware de Geolocalização para PcD.\n\nDesenvolvido por:\nFrancisco Nogueira Barboza\nMatheus Gouvea dos Santos\n2023',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[200] : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
