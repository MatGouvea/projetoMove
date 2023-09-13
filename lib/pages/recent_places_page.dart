import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:projeto_move/pages/settings_page.dart';
import 'package:projeto_move/utils/constants.dart';
import 'package:provider/provider.dart';
import '../components/is_recent_list.dart';
import '../components/map_controller_holder.dart';

class RecentPlacesPage extends StatefulWidget {
  const RecentPlacesPage({super.key});

  @override
  State<RecentPlacesPage> createState() => _RecentPlacesPageState();
}

class _RecentPlacesPageState extends State<RecentPlacesPage> {
  @override
  Widget build(BuildContext context) {
    final recentPlaces = Provider.of<IsRecentList>(context);
    final settings = Provider.of<SettingsPage>(context);
    final isDarkMode = settings.isDarkMode;
    final fontSize = settings.fontSize;
    return Scaffold(
      backgroundColor: isDarkMode ? darkMainColor : null,
      body: Column(children: [
        const SizedBox(height: 40),
        Row(
          children: [
            const SizedBox(width: 15),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
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
                  'Locais recentes',
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
        recentPlaces.length > 0
            ? Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  shrinkWrap: true,
                  itemCount: recentPlaces.length,
                  itemBuilder: (ctx, i) {
                    var reversePlaces = recentPlaces.reverse();
                    var place = reversePlaces[i];
                    final randomIndex = Random().nextInt(place.images!.length);
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        MapControllerHolder.mapController.animateCamera(
                            CameraUpdate.newCameraPosition(CameraPosition(
                                target: place.position!, zoom: 16, tilt: 40)));
                      },
                      child: Card(
                        color: isDarkMode ? secDarkMainColor : null,
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 20),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        place.name,
                                        style: TextStyle(
                                            fontSize: fontSize == 0 ? 20 : 25,
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
                                      color:
                                          isDarkMode ? Colors.grey[400] : null,
                                      fontSize: fontSize == 0 ? null : 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 330),
                  Center(
                    child: Text(
                      'Nenhum local visualizado recentemente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize == 0 ? 20 : 25,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : null,
                      ),
                    ),
                  ),
                ],
              ),
      ]),
    );
  }
}
