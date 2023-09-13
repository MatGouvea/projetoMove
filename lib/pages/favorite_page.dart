import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:projeto_move/components/delete_dialog.dart';
import 'package:projeto_move/data/mock_data.dart';
import 'package:provider/provider.dart';
import '../components/favorite_list.dart';
import '../components/map_controller_holder.dart';
import '../models/each_place.dart';
import '../utils/constants.dart';
import 'settings_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  Future<List<EachPlace>> getFavoritePlaces() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final favoritesRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final doc = await favoritesRef.get();

      if (doc.exists) {
        final favoriteIds = List<int>.from(doc.get('favoritePlaces'));

        final favoritePlaces = detailedPlaces
            .where((place) => favoriteIds.contains(place.id))
            .toList();

        return favoritePlaces;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

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
    final favoriteList = Provider.of<FavoriteList>(context);
    final settings = Provider.of<SettingsPage>(context);
    final isDarkMode = settings.isDarkMode;
    final isTts = settings.isTts;
    final fontSize = settings.fontSize;
    return Scaffold(
      backgroundColor: isDarkMode ? darkMainColor : null,
      body: Column(
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
                    'Locais salvos',
                    style: TextStyle(
                        fontSize: fontSize == 0 ? 20 : 25,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : null),
                  ),
                  Text(
                    'Toque em um local para ir até ele',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : null,
                      fontSize: fontSize == 0 ? null : 20,
                    ),
                  ),
                  const SizedBox(height: 10)
                ],
              )
            ],
          ),
          FutureBuilder<List<EachPlace>>(
            future: getFavoritePlaces(),
            builder: ((context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Column(
                  children: [
                    const SizedBox(height: 330),
                    Center(
                      child: Text(
                        'Nenhum local foi salvo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: fontSize == 0 ? 20 : 25,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : null),
                      ),
                    ),
                  ],
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(children: [
                  const SizedBox(height: 330),
                  LoadingAnimationWidget.prograssiveDots(
                    color: isDarkMode ? Colors.white : mainColor,
                    size: 50,
                  ),
                ]);
              } else {
                final favoritePlaces = snapshot.data;
                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    shrinkWrap: true,
                    itemCount: favoritePlaces!.length,
                    itemBuilder: (ctx, i) {
                      var reversedPlaces = favoritePlaces.reversed.toList();
                      var place = reversedPlaces[i];
                      final randomIndex =
                          Random().nextInt(place.images!.length);
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Dismissible(
                            direction: DismissDirection.endToStart,
                            background: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.red[700],
                                  ),
                                  margin: const EdgeInsets.only(
                                      top: 10, left: 15, right: 15, bottom: 20),
                                ),
                                const Positioned(
                                  right: 30,
                                  top: 1,
                                  bottom: 1,
                                  child: Icon(
                                    Icons.delete_sweep,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                )
                              ],
                            ),
                            onDismissed: (_) {
                              setState(() {
                                place.toggleFavorite(favoriteList);
                                speak(
                                    "${place.name} removido dos locais salvos",
                                    isTts);
                              });
                            },
                            key: Key(place.toString()),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                MapControllerHolder.mapController.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                            target: place.position!,
                                            zoom: 16,
                                            tilt: 40)));
                              },
                              child: Card(
                                color: isDarkMode ? secDarkMainColor : null,
                                margin: const EdgeInsets.only(
                                    top: 10, left: 15, right: 15, bottom: 20),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                elevation: 8,
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15)),
                                      child: place.images![randomIndex],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                place.name,
                                                style: TextStyle(
                                                    fontSize:
                                                        fontSize == 0 ? 20 : 25,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : null),
                                              ),
                                              const SizedBox(width: 5),
                                              Icon(
                                                place.icon,
                                                color: isDarkMode
                                                    ? Colors.grey[400]
                                                    : Colors.grey,
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            place.address,
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.grey[400]
                                                  : null,
                                              fontSize: fontSize == 0 ? null : 20
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -7,
                            right: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15))),
                              onPressed: () async {
                                final bool deleteConfirmed = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const DeleteDialog();
                                  },
                                );
                                if (deleteConfirmed) {
                                  setState(() {
                                    place.toggleFavorite(favoriteList);
                                    speak(
                                        "${place.name} removido dos locais salvos",
                                        isTts);
                                  });
                                }
                              },
                              child:  Row(
                                children: [
                                  const Icon(Icons.star),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Remover',
                                    style: TextStyle(fontSize: fontSize == 0 ? 18 : 23,),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
