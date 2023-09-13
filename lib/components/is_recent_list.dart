import 'package:flutter/material.dart';
import '../models/each_place.dart';

class IsRecentList with ChangeNotifier {
  final int _maxSize = 5;
  final List<EachPlace> _list = [];

  void add(EachPlace element) {
    if (_list.contains(element)) {
      _list.remove(element);
      notifyListeners();
    }

    if (_list.length >= _maxSize) {
      _list.removeAt(0);
      notifyListeners();
    }
    _list.add(element);
    notifyListeners();
  }

  int get length => _list.length;

  EachPlace operator [](int index) => _list[index];

  List<EachPlace> reverse() {
    final reversedList = <EachPlace>[];
    for (var i = _list.length - 1; i >= 0; i--) {
      reversedList.add(_list[i]);
    }
    return reversedList;
  }

  @override
  String toString() => _list.toString();
}