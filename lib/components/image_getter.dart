
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/.env';

class ImageGetter extends StatelessWidget {
  final String userId;

  const ImageGetter({super.key, required this.userId});

  Future<String?> getImageUrl() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      final data = snapshot.data();
      return data?['image'];
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getImageUrl(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return SizedBox(
              height: 100, width: 100, child: Image.network(snapshot.data!, fit: BoxFit.cover));
        } else {
          return Image.network(defaultImageUrl);
        }
      },
    );
  }
}
