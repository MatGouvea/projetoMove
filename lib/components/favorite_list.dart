import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_move/models/each_place.dart';

class FavoriteList with ChangeNotifier {
  List<EachPlace> _favoritePlaces = [];

  List<EachPlace> get favoritePlaces => _favoritePlaces;

  void addFavoritePlace(EachPlace place) async {
    if (place.isFavorite) {
      _favoritePlaces.add(place);
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final favoritesRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        final favoritePlaceIds = _favoritePlaces.map((p) => p.id).toList();

        await favoritesRef.set({
          'favoritePlaces': favoritePlaceIds,
        }, SetOptions(merge: true));
      }
    }
  }

  void removeFavoritePlace(EachPlace place) async {
    _favoritePlaces.remove(place);
    _favoritePlaces = _favoritePlaces.toList();
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final favoritesRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await favoritesRef.update({
        'favoritePlaces': FieldValue.arrayRemove([place.id])
      });
    }
  }

  int get length => _favoritePlaces.length;

  EachPlace operator [](int index) => _favoritePlaces[index];

  @override
  String toString() => _favoritePlaces.toString();
}
