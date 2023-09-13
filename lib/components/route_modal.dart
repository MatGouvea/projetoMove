import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../pages/settings_page.dart';
import '../utils/constants.dart';
import 'map_controller_holder.dart';
import '/components/marker_manager.dart';
import '../utils/.env';

class RouteModal extends StatefulWidget {
  final BitmapDescriptor startIcon;
  final BitmapDescriptor endIcon;
  final Function(double) callback;
  final Position currentLocation;

  const RouteModal(
      {super.key,
      required this.startIcon,
      required this.endIcon,
      required this.callback,
      required this.currentLocation});

  @override
  State<RouteModal> createState() => _RouteModalState();
}

late Marker startMarker;
late Marker endMarker;

late List<Placemark> startPlacemarks;
late List<Placemark> endPlacemarks;
late List<Placemark> currentLocationPlacemarks;

Set<Polyline> polylines = Set<Polyline>();

class _RouteModalState extends State<RouteModal> {
  late double _distance;

  _switchModal() async {
    Navigator.of(context).pop();
  }

  _getPlaceMark() async {
    currentLocationPlacemarks = await placemarkFromCoordinates(
      widget.currentLocation.latitude,
      widget.currentLocation.longitude,
    );
  }

  @override
  void initState() {
    super.initState();
    _getPlaceMark();
  }

  final FocusNode _startFocusNode = FocusNode();
  final FocusNode _endFocusNode = FocusNode();

  TextEditingController startAddressController = TextEditingController();
  TextEditingController destinationAddressController = TextEditingController();
  TextEditingController holderController = TextEditingController();

  FlutterTts flutterTts = FlutterTts();

  String _startAddress = '';
  String _endAddress = '';

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

  Future<void> calculateRoute() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    late LatLng _startCoordinates;
    late LatLng _endCoordinates;

    List<Location> startLocations = await locationFromAddress(_startAddress);
    List<Location> endLocations = await locationFromAddress(_endAddress);

    _startCoordinates =
        LatLng(startLocations.first.latitude, startLocations.first.longitude);
    _endCoordinates =
        LatLng(endLocations.first.latitude, endLocations.first.longitude);

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        mapsApiKey,
        PointLatLng(_startCoordinates.latitude, _startCoordinates.longitude),
        PointLatLng(_endCoordinates.latitude, _endCoordinates.longitude),
        travelMode: TravelMode.walking,
        avoidHighways: true,
        avoidFerries: true);
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
    }

    MarkerManager().addMarker(startMarker = Marker(
        markerId: const MarkerId('start'),
        position: _startCoordinates,
        icon: widget.startIcon));
    MarkerManager().addMarker(endMarker = Marker(
        markerId: const MarkerId('end'),
        position: _endCoordinates,
        icon: widget.endIcon));

    polylines.clear();
    polylines.add(Polyline(
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      polylineId: const PolylineId('route'),
      points: polylineCoordinates,
      color: mainColor,
      width: 5,
    ));

    MapControllerHolder.mapController;

    MapControllerHolder.mapController.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
            target:
                LatLng(_startCoordinates.latitude, _startCoordinates.longitude),
            zoom: 16,
            tilt: 40)));

    _distance = await Geolocator.distanceBetween(
        _startCoordinates.latitude,
        _startCoordinates.longitude,
        _endCoordinates.latitude,
        _endCoordinates.longitude);
    widget.callback(_distance);

    startPlacemarks = await placemarkFromCoordinates(
        _startCoordinates.latitude, _startCoordinates.longitude);
    endPlacemarks = await placemarkFromCoordinates(
        _endCoordinates.latitude, _endCoordinates.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsPage>(context);
    final isDarkMode = settings.isDarkMode;
    final isTts = settings.isTts;
    final fontSize = settings.fontSize;
    return Material(
      color: isDarkMode ? darkMainColor : null,
      shape: Border.all(width: 0),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? darkMainColor : null,
        ),
        height: 640 / 2 + MediaQuery.of(context).viewInsets.bottom,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(
              top: 10,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TextField Partida
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? secDarkMainColor : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    TextField(
                      cursorColor: mainColor,
                      focusNode: _startFocusNode,
                      controller: startAddressController,
                      onChanged: (value) {
                        setState(() {
                          _startAddress = value;
                        });
                      },
                      style: TextStyle(
                          fontSize: fontSize == 0 ? 20 : 25,
                          color: isDarkMode ? Colors.white : null),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                            fontSize: fontSize == 0 ? 20 : 25,
                            color: isDarkMode ? Colors.white : null),
                        prefixIconColor: isDarkMode ? Colors.white : mainColor,
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          size: 30,
                        ),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none),
                        hintText: 'Ponto de partida..',
                      ),
                    ),
                    Positioned(
                      right: -5,
                      bottom: 6,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(1),
                              backgroundColor: mainColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          onPressed: () {
                            startAddressController.text =
                                currentLocationPlacemarks[0].street!;
                          },
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              IconButton(
                onPressed: () {
                  setState(() {
                    holderController.text = startAddressController.text;
                    startAddressController.text =
                        destinationAddressController.text;
                    destinationAddressController.text = holderController.text;
                  });
                },
                icon: const Icon(
                  Icons.swap_vert,
                  color: mainColor,
                  size: 35,
                ),
              ),
              const SizedBox(height: 15),
              // TextField Destino
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? secDarkMainColor : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  cursorColor: mainColor,
                  focusNode: _endFocusNode,
                  controller: destinationAddressController,
                  onChanged: (value) {
                    setState(() {
                      _endAddress = value;
                    });
                  },
                  style: TextStyle(
                      fontSize: fontSize == 0 ? 20 : 25,
                      color: isDarkMode ? Colors.white : null),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                        fontSize: fontSize == 0 ? 20 : 25,
                        color: isDarkMode ? Colors.white : null),
                    prefixIconColor: isDarkMode ? Colors.white : mainColor,
                    prefixIcon: const Icon(
                      Icons.pin_drop_outlined,
                      size: 30,
                    ),
                    border:
                        const OutlineInputBorder(borderSide: BorderSide.none),
                    hintText: 'Destino..',
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Botão Criar Rota
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 352.5,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 8,
                          backgroundColor: mainColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          )),
                      onPressed: () {
                        speak("Desenhando a melhor rota", isTts);
                        calculateRoute();
                        _endFocusNode.unfocus();
                        _startFocusNode.unfocus();
                        Future.delayed(
                            const Duration(seconds: 2), _switchModal);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Criar rota',
                            style: TextStyle(
                                fontSize: fontSize == 0 ? 20 : 25,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 10),
                          Transform.rotate(
                            angle: 90 * math.pi / 180,
                            child: const Icon(
                              Icons.navigation,
                              size: 30,
                            ),
                          )
                        ],
                      ),
                    ),
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
