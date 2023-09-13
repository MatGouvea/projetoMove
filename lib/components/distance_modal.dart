import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:projeto_move/components/marker_manager.dart';
import 'package:projeto_move/components/route_modal.dart';
import 'package:projeto_move/utils/constants.dart';
import 'package:provider/provider.dart';

import '../pages/settings_page.dart';

class DistanceModal extends StatelessWidget {
  final double distance;
  final Function() resetDistance;

  const DistanceModal({super.key, required this.distance, required this.resetDistance});

  Future<String> fetchStart() async {
    return startPlacemarks[0].street!;
  }

  Future<String> fetchEnd() async {
    return endPlacemarks[0].street!;
  }

  @override
  Widget build(BuildContext context) {
    double distanceInKm = distance / 1000;
    final settings = Provider.of<SettingsPage>(context);
    final isDarkMode = settings.isDarkMode;
    return SizedBox(
      height: 215,
      width: 390,
      child: Card(
        elevation: 8,
        color: isDarkMode ? darkMainColor : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10,
            left: 20,
            right: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(
                        Icons.location_on,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Partida',
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                  FutureBuilder(
                      future: fetchStart(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('');
                        } else {
                          return Text(
                            startPlacemarks[0].street!,
                            style: TextStyle(
                                fontSize: 18,
                                color: isDarkMode ? Colors.white : null),
                          );
                        }
                      }),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(
                        Icons.pin_drop,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Destino',
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                  FutureBuilder(
                      future: fetchEnd(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('');
                        } else {
                          return Text(
                            endPlacemarks[0].street!,
                            style: TextStyle(
                                fontSize: 18,
                                color: isDarkMode ? Colors.white : null),
                          );
                        }
                      }),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      onPressed: () {
                        resetDistance();
                        MarkerManager().removeMarker(startMarker);
                        MarkerManager().removeMarker(endMarker);
                        polylines.clear();
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.cancel),
                          SizedBox(width: 5),
                          Text(
                            'Cancelar',
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      LoadingAnimationWidget.prograssiveDots(
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        distance >= 1000
                            ? 'Distância: ${distanceInKm.toStringAsFixed(2)} km.'
                            : 'Distância: ${distance.toStringAsFixed(2)} metros.',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : null),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
