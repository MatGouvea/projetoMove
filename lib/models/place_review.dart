import '../components/place_modal.dart';

class PlaceReview {
  String userName;
  double rating;
  String comment;
  String imageUrl;

  PlaceReview({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.imageUrl
  });

  Map<String, dynamic> toMap() {
    return {
      'id': user!.uid,
      'name': userName,
      'rating': rating,
      'comment': comment,
      'image': imageUrl
    };
  }

  factory PlaceReview.fromMap(Map<String, dynamic> map) {
    return PlaceReview(
      userName: map['name'],
      comment: map['comment'],
      rating: map['rating'],
      imageUrl: map['image']
    );
  }

}