// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projeto_move/components/distance_modal.dart';
import 'package:projeto_move/pages/loading_page.dart';
import 'package:projeto_move/pages/settings_page.dart';
import 'package:provider/provider.dart';
import '../components/app_drawer.dart';
import '../components/is_recent_list.dart';
import '../components/map_controller_holder.dart';
import '../components/marker_manager.dart';
import '../components/place_modal.dart';
import '../components/route_modal.dart';
import '../components/widget_search_bar.dart';
import '../data/mock_data.dart';
import '../utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../components/map_style_holder.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double _distance = 0;
  double get distance => _distance;

  FlutterTts flutterTts = FlutterTts();

  void updateDistance(double distance) {
    setState(() {
      _distance = distance;
    });
  }

  resetDistance() {
    setState(() {
      _distance = 0;
    });
  }

  void speak(String text, bool isTts) async {
    if (isTts) {
      await flutterTts.setLanguage('pt-BR');
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(text);
    }
  }

  //Abrir modal de rotas
  _openRouteModal(BuildContext context) {
    showModalBottomSheet(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return RouteModal(
          startIcon: startIcon,
          endIcon: endIcon,
          callback: updateDistance,
          currentLocation: currentLocation!,
        );
      },
    );
  }

  //Modal de cada local
  _openPlaceModal(BuildContext context, int destinationIndex) {
    final isRecent = Provider.of<IsRecentList>(context, listen: false);
    final settings = Provider.of<SettingsPage>(context, listen: false);
    final isTts = settings.isTts;
    setState(() {
      isRecent.add(detailedPlaces[destinationIndex]);
    });
    showModalBottomSheet(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return PlaceModal(place: detailedPlaces[destinationIndex]);
      },
    );
    speak("Visualizando ${detailedPlaces[destinationIndex].name}", isTts);
  }

  late BitmapDescriptor userIcon;
  late BitmapDescriptor destinationIcon;
  late BitmapDescriptor schoolIcon;
  late BitmapDescriptor publicIcon;
  late BitmapDescriptor startIcon;
  late BitmapDescriptor endIcon;
  late BitmapDescriptor shopIcon;
  late BitmapDescriptor foodIcon;
  late BitmapDescriptor drugsIcon;
  late BitmapDescriptor hospitalIcon;

  late GoogleMapController mapController;

  Position? currentLocation;

  //Pegar Localização atual
  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        FloatingSnackBar(
            message: 'Você precisa permitir o acesso a localização.',
            context: context,
            textStyle: const TextStyle(fontSize: 18));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      FloatingSnackBar(
          message: 'Você precisa permitir o acesso a localização.',
          context: context,
          textStyle: const TextStyle(fontSize: 18));
      return;
    }

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)),
            'assets/images/start_pin.png')
        .then((d) {
      startIcon = d;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)),
            'assets/images/end_pin.png')
        .then((d) {
      endIcon = d;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)),
            'assets/images/user_pin.png')
        .then((d) {
      userIcon = d;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)),
            'assets/images/school_pin.png')
        .then((d) {
      schoolIcon = d;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)),
            'assets/images/hospital_pin.png')
        .then((d) {
      hospitalIcon = d;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)),
            'assets/images/drugs_pin.png')
        .then((d) {
      drugsIcon = d;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)),
            'assets/images/shop_pin.png')
        .then((d) {
      shopIcon = d;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)),
            'assets/images/food_pin.png')
        .then((d) {
      foodIcon = d;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)),
            'assets/images/public_pin.png')
        .then((d) {
      publicIcon = d;
    });

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLocation = position;
      //Marker do usuário
      MarkerManager().addMarker(Marker(
          icon: userIcon,
          markerId: const MarkerId('currentLocation'),
          position:
              LatLng(currentLocation!.latitude, currentLocation!.longitude)));
      //Marker Fatec
      //
      MarkerManager().addMarker(
        Marker(
          onTap: () {
            _openPlaceModal(context, 0);
          },
          markerId: const MarkerId('0'),
          icon: schoolIcon,
          position: const LatLng(-23.013689983555874, -45.53620988178109),
        ),
      );
      //Marker Rodoviária velha
      //
      MarkerManager().addMarker(
        Marker(
          onTap: () {
            _openPlaceModal(context, 1);
          },
          markerId: const MarkerId('1'),
          icon: publicIcon,
          position: const LatLng(-23.022624831792577, -45.55927886023051),
        ),
      );
      //Marker Golden Mix
      //
      MarkerManager().addMarker(
        Marker(
          onTap: () {
            _openPlaceModal(context, 2);
          },
          markerId: const MarkerId('2'),
          icon: shopIcon,
          position: const LatLng(-23.026163899999993, -45.55576640731722),
        ),
      );
      //Marker Café chicão
      //
      MarkerManager().addMarker(
        Marker(
          onTap: () {
            _openPlaceModal(context, 3);
          },
          markerId: const MarkerId('3'),
          icon: foodIcon,
          position: const LatLng(-23.02438891131926, -45.55474774122327),
        ),
      );
      //Marker Boulevard Rio Branco
      MarkerManager().addMarker(
        Marker(
          onTap: () {
            _openPlaceModal(context, 4);
          },
          markerId: const MarkerId('4'),
          icon: shopIcon,
          position: const LatLng(-23.024687830804854, -45.554709904777305),
        ),
      );
      //Marker drogaquinze epaminondas
      MarkerManager().addMarker(
        Marker(
          onTap: () {
            _openPlaceModal(context, 5);
          },
          markerId: const MarkerId('5'),
          icon: drugsIcon,
          position: const LatLng(-23.026911003199682, -45.55502310879746),
        ),
      );
      //Marker Lojas torra
      MarkerManager().addMarker(
        Marker(
          onTap: () {
            _openPlaceModal(context, 6);
          },
          markerId: const MarkerId('6'),
          icon: shopIcon,
          position: const LatLng(-23.024981939003712, -45.55565112489212),
        ),
      );
      //Marker jordania e mattos
      MarkerManager().addMarker(
        Marker(
          onTap: () {
            _openPlaceModal(context, 7);
          },
          markerId: const MarkerId('7'),
          icon: hospitalIcon,
          position: const LatLng(-23.023182216558197, -45.554670388124656),
        ),
      );
      //Marker Caedu
      MarkerManager().addMarker(
        Marker(
          onTap: () {
            _openPlaceModal(context, 8);
          },
          markerId: const MarkerId('8'),
          icon: shopIcon,
          position: const LatLng(-23.02489516365942, -45.55496028790236),
        ),
      );
      //Marker new big
      MarkerManager().addMarker(
        Marker(
          onTap: () {
            _openPlaceModal(context, 9);
          },
          markerId: const MarkerId('9'),
          icon: shopIcon,
          position: const LatLng(-23.025058826813986, -45.55537221064327),
        ),
      );
      //Marker Americanas Express
      MarkerManager().addMarker(
        Marker(
          onTap: () {
            _openPlaceModal(context, 10);
          },
          markerId: const MarkerId('10'),
          icon: shopIcon,
          position: const LatLng(-23.025206591133802, -45.55528669502774),
        ),
      );
      //Marker Tennisbar
      MarkerManager().addMarker(
        Marker(
          onTap: () {
            _openPlaceModal(context, 11);
          },
          markerId: const MarkerId('11'),
          icon: shopIcon,
          position: const LatLng(-23.02590999869277, -45.555141953695646),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    polylines.clear();
    MarkerManager().markers.clear();
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
    final isZoomHide = settings.isZoomHide;
    final isTts = settings.isTts;
    return Scaffold(
      drawer: AppDrawer(),
      backgroundColor: Colors.white,
      body: currentLocation == null
          ? const LoadingPage()
          : Stack(
              children: [
                //O Mapa
                Consumer<SettingsPage>(
                  builder: (context, settings, _) {
                    final isDarkMode = settings.isDarkMode;
                    return Consumer<MarkerManager>(
                      builder: ((context, markers, child) {
                        return Container(
                          color: Colors.grey[800],
                          child: GoogleMap(
                              mapToolbarEnabled: false,
                              onMapCreated: (GoogleMapController controller) {
                                MapControllerHolder.mapController = controller;
                                MapControllerHolder.mapController.setMapStyle(
                                    isDarkMode ? darkMapStyle : null);
                              },
                              myLocationButtonEnabled: false,
                              compassEnabled: false,
                              zoomControlsEnabled: false,
                              padding: const EdgeInsets.only(top: 30),
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(currentLocation!.latitude,
                                      currentLocation!.longitude),
                                  zoom: 16,
                                  tilt: 40),
                              polylines: polylines,
                              markers: MarkerManager().markers),
                        );
                      }),
                    );
                  },
                ),
                //Interface Inferior
                Positioned.fill(
                  top: 130,
                  right: 15,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      width: 55,
                      height: 55,
                      child: FloatingActionButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 8,
                        backgroundColor:
                            isDarkMode ? secDarkMainColor : Colors.white,
                        onPressed: () {
                          speak("Voltando à sua posição no mapa", isTts);
                          MapControllerHolder.mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                  target: LatLng(currentLocation!.latitude,
                                      currentLocation!.longitude),
                                  zoom: 16,
                                  tilt: 40),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.my_location,
                          size: 35,
                          color: isDarkMode ? Colors.white : mainColor,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isZoomHide == false)
                  Positioned.fill(
                    bottom: 30,
                    left: 120,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: 70,
                        height: 55,
                        child: FloatingActionButton(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          )),
                          elevation: 8,
                          backgroundColor:
                              isDarkMode ? secDarkMainColor : Colors.white,
                          onPressed: () {
                            speak("Diminuindo zoom", isTts);
                            MapControllerHolder.mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                          child: Icon(
                            Icons.zoom_out,
                            size: 35,
                            color: isDarkMode ? Colors.white : mainColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (isZoomHide == false)
                  Positioned.fill(
                    bottom: 30,
                    right: 120,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: 70,
                        height: 55,
                        child: FloatingActionButton(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          )),
                          elevation: 8,
                          backgroundColor:
                              isDarkMode ? secDarkMainColor : Colors.white,
                          onPressed: () {
                            speak("Aumentando zoom", isTts);
                            MapControllerHolder.mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                          child: Icon(
                            Icons.zoom_in,
                            size: 35,
                            color: isDarkMode ? Colors.white : mainColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                //Modal de rotas
                //
                Positioned.fill(
                  bottom: 20,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: FloatingActionButton(
                        elevation: 8,
                        backgroundColor: mainColor,
                        onPressed: () {
                          _openRouteModal(context);
                          speak("Informe um endereço de partida e de chegada para criar uma rota", isTts);
                        },
                        child: const Icon(
                          Icons.route,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
                //Barra de pesquisa
                WidgetSearchBar(),
                if (distance != 0)
                  Positioned(
                      bottom: 1,
                      child: DistanceModal(
                        distance: distance,
                        resetDistance: resetDistance,
                      ))
              ],
            ),
    );
  }
}
