import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapControllerHolder {
  static late GoogleMapController mapController;

  static setMapController(GoogleMapController controller) {
    mapController = controller;
  }
}