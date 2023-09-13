import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerManager with ChangeNotifier{
  static final MarkerManager _instance = MarkerManager._internal();

  final Set<Marker> _markers = {};

  factory MarkerManager() {
    return _instance;
  }

  MarkerManager._internal();

  Set<Marker> get markers => _markers;

  void addMarker(Marker marker) {
    _markers.add(marker);
    notifyListeners();
  }

  void removeMarker(Marker marker) {
    _markers.remove(marker);
    notifyListeners();
  }

}