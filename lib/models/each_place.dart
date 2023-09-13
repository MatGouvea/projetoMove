import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:projeto_move/models/place_review.dart';

import '../components/favorite_list.dart';

enum Viable {isViable, isNotViable, midViable}

class EachPlace {
  int id;
  String name;
  String address;
  String type;
  List<Image>? images;
  IconData icon;
  Viable? wheelchairViability;
  Viable? blindViability;
  Viable? deafViability;
  Iterable<String>? wheelchairViableDescription;
  Iterable<String>? blindViableDescription;
  Iterable<String>? deafViableDescription;
  LatLng? position;
  bool isFavorite;
  List<PlaceReview>? reviews;

  EachPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    this.images,
    required this.icon,
    this.wheelchairViability,
    this.blindViability,
    this.deafViability,
    this.wheelchairViableDescription,
    this.blindViableDescription,
    this.deafViableDescription,
    this.position,
    this.isFavorite = false,
    this.reviews,
  });
  
  void toggleFavorite(FavoriteList favoriteList) {
    isFavorite = !isFavorite;
    if (isFavorite) {
      favoriteList.addFavoritePlace(this);
    } else {
      favoriteList.removeFavoritePlace(this);
    }
  }
}