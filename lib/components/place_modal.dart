import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:projeto_move/components/viability_form.dart';
import 'package:projeto_move/components/widget_rating_bar.dart';
import 'package:provider/provider.dart';
import '../models/each_place.dart';
import '../models/place_review.dart';
import '../pages/settings_page.dart';
import '../utils/constants.dart';
import 'delete_dialog.dart';
import 'favorite_list.dart';
import 'image_getter.dart';
import '../utils/.env';

class PlaceModal extends StatefulWidget {
  final EachPlace place;
  const PlaceModal({super.key, required this.place});

  @override
  State<PlaceModal> createState() => _PlaceModalState();
}

final User? user = FirebaseAuth.instance.currentUser;

late List<Placemark> currentLocationPlacemarks;

Icon checkIcon = const Icon(Icons.check_rounded, color: Colors.green);
Icon warningIcon = Icon(Icons.priority_high, color: Colors.yellow[600]);
Icon uncheckIcon = const Icon(Icons.close, color: Colors.red);

bool wheelchairIsVisible = false;
bool blindIsVisible = false;
bool deafIsVisible = false;

class _PlaceModalState extends State<PlaceModal> {
  late double rating;
  String comment = '';
  ImageGetter image = ImageGetter(userId: user!.uid);

  @override
  initState() {
    super.initState();
    _getPlaceMark();
    checkExistingReview();
  }

  void sendReview(PlaceReview review) {
    final collectionRef = FirebaseFirestore.instance.collection('reviews');
    final documentRef = collectionRef
        .doc(widget.place.id.toString())
        .collection('review')
        .doc();

    final data = review.toMap();

    documentRef.set(data);
  }

  void addReview() async {
    List<PlaceReview> reviews = widget.place.reviews ?? [];
    String imageUrl =
        (await image.getImageUrl())?.toString() ?? defaultImageUrl;

    PlaceReview newReview = PlaceReview(
        userName: user!.displayName!,
        rating: rating,
        comment: comment,
        imageUrl: imageUrl);

    reviews.add(newReview);
    sendReview(newReview);

    widget.place.reviews = reviews;

    setState(() {});
  }

  void deleteReview() async {
    List<PlaceReview> reviews = widget.place.reviews ?? [];
    final collectionRef = FirebaseFirestore.instance.collection('reviews');
    final querySnapshot = await collectionRef
        .doc(widget.place.id.toString())
        .collection('review')
        .where('id', isEqualTo: user!.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final reviewDocument = querySnapshot.docs.first;
      await reviewDocument.reference.delete();
    }
    await checkExistingReview();

    int index =
        reviews.indexWhere((review) => review.userName == user!.displayName!);

    if (index != -1) {
      reviews.removeAt(index);
      widget.place.reviews = reviews;

      setState(() {});
    }
  }

  _getPlaceMark() async {
    currentLocationPlacemarks = await placemarkFromCoordinates(
      widget.place.position!.latitude,
      widget.place.position!.longitude,
    );
  }

  void ratingCallback(double? userRating) {
    rating = userRating ?? 3.0;
  }

  void commentCallback(String? userComment) {
    comment = userComment ?? '';
  }

  List<Map<String, dynamic>> sortReviews(
      List<Map<String, dynamic>> reviews, String userId) {
    reviews.sort((a, b) {
      final aIsCurrentUser = a['id'] == userId;
      final bIsCurrentUser = b['id'] == userId;

      if (aIsCurrentUser && !bIsCurrentUser) {
        return -1;
      } else if (!aIsCurrentUser && bIsCurrentUser) {
        return 1;
      }

      return 0;
    });

    return reviews;
  }

  bool hasExistingReview = false;

  Future<void> checkExistingReview() async {
    final collectionRef = FirebaseFirestore.instance.collection('reviews');
    final documentRef = await collectionRef
        .doc(widget.place.id.toString())
        .collection('review')
        .where('id', isEqualTo: user!.uid)
        .limit(1)
        .get();

    hasExistingReview = documentRef.docs.isNotEmpty;
    setState(() {});
  }

  openViabilityForm(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return Center(child: ViabilityForm(placeId: widget.place.id));
        });
  }

  FlutterTts flutterTts = FlutterTts();

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

  @override
  Widget build(BuildContext context) {
    List<PlaceReview> reviews = widget.place.reviews ?? [];

    reviews.sort((a, b) {
      if (a.userName == user!.displayName!) {
        return -1;
      } else if (b.userName == user!.displayName!) {
        return 1;
      } else {
        return 0;
      }
    });

    final favoritePlaces = Provider.of<FavoriteList>(context);
    final settings = Provider.of<SettingsPage>(context);
    final isDarkMode = settings.isDarkMode;
    final isTts = settings.isTts;
    final fontSize = settings.fontSize;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 500),
          child: Container(
            color: isDarkMode ? darkMainColor : null,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              //Nome e descrição do local
              //
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.place.icon,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        children: [
                          Text(
                            widget.place.name,
                            style: TextStyle(
                                fontSize: fontSize == 0 ? 20 : 25,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : null),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            widget.place.type,
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : null,
                              fontSize: fontSize == 0 ? null : 20,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(width: 35)
                    ],
                  ),
                  Divider(color: isDarkMode ? Colors.grey[800] : null),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 180,
                            //Imagens do local
                            //
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.place.images!.length,
                                itemBuilder: (ctx, i) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: SizedBox(
                                      width: 240,
                                      height: 240,
                                      child: widget.place.images![i],
                                    ),
                                  );
                                }),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color:
                                    isDarkMode ? Colors.grey[400] : Colors.grey,
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  widget.place.address,
                                  style: TextStyle(
                                      fontSize: fontSize == 0 ? 16 : 21,
                                      color:
                                          isDarkMode ? Colors.grey[400] : null),
                                ),
                              ),
                            ],
                          ),
                          Divider(color: isDarkMode ? Colors.grey[800] : null),
                          const SizedBox(height: 10),
                          Text(
                            'Viabilidade',
                            style: TextStyle(
                                fontSize: fontSize == 0 ? 20 : 25,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : null),
                          ),
                          Text('Toque em cada categoria para mais detalhes',
                              style: TextStyle(
                                  fontSize: fontSize == 0 ? 16 : 21,
                                  color: isDarkMode ? Colors.grey[400] : null)),
                          const SizedBox(height: 25),
                          //Barra Cadeirante
                          //
                          GestureDetector(
                            onTap: () {
                              if (!wheelchairIsVisible &&
                                  widget.place.wheelchairViability != null) {
                                speak(
                                    "Para deficientes físicos, ${widget.place.name} é ${widget.place.wheelchairViability == Viable.isViable ? 'Viável' : widget.place.wheelchairViability == Viable.midViable ? 'Parcialmente viável' : 'Inviável'}, ele possui: ${widget.place.wheelchairViableDescription.toString()}",
                                    isTts);
                              }
                              if (widget.place.wheelchairViableDescription!
                                  .isNotEmpty) {
                                setState(() {
                                  wheelchairIsVisible = !wheelchairIsVisible;
                                });
                              }
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: 55,
                                  top: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: widget.place
                                                    .wheelchairViability ==
                                                Viable.isViable
                                            ? Colors.green[600]
                                            : widget.place
                                                        .wheelchairViability ==
                                                    Viable.midViable
                                                ? Colors.yellow[800]
                                                : widget.place
                                                            .wheelchairViability ==
                                                        Viable.isNotViable
                                                    ? Colors.red[600]
                                                    : Colors.grey[600],
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(15))),
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 10),
                                    child: const Text(
                                      'Deficiente físico',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Card(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(15),
                                              bottomRight:
                                                  Radius.circular(15))),
                                      elevation: 8,
                                      margin: const EdgeInsets.only(
                                          left: 50, right: 25, top: 4),
                                      color: widget.place.wheelchairViability ==
                                              Viable.isViable
                                          ? Colors.green
                                          : widget.place.wheelchairViability ==
                                                  Viable.midViable
                                              ? Colors.yellow[700]
                                              : widget.place
                                                          .wheelchairViability ==
                                                      Viable.isNotViable
                                                  ? Colors.red
                                                  : Colors.grey,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 7),
                                        child: Text(
                                          widget.place.wheelchairViability ==
                                                  Viable.isViable
                                              ? 'Viável'
                                              : widget.place
                                                          .wheelchairViability ==
                                                      Viable.midViable
                                                  ? 'Parcialmente viável'
                                                  : widget.place
                                                              .wheelchairViability ==
                                                          Viable.isNotViable
                                                      ? 'Inviável'
                                                      : 'Sem informações',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: fontSize == 0 ? 20 : 25,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 20,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: widget.place.wheelchairViability ==
                                              Viable.isViable
                                          ? Colors.green[600]
                                          : widget.place.wheelchairViability ==
                                                  Viable.midViable
                                              ? Colors.yellow[800]
                                              : widget.place
                                                          .wheelchairViability ==
                                                      Viable.isNotViable
                                                  ? Colors.red[600]
                                                  : Colors.grey[600],
                                    ),
                                    width: 60,
                                    height: 60,
                                    child: const Icon(
                                      Icons.accessible_forward,
                                      color: Colors.white,
                                      size: 45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //Descrição cadeirante
                          //
                          Visibility(
                            visible: wheelchairIsVisible,
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 25, right: 25, top: 25),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: isDarkMode
                                          ? Colors.grey[800]!
                                          : Colors.black)),
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: widget.place
                                        .wheelchairViableDescription?.length ??
                                    0,
                                itemBuilder: (ctx, i) {
                                  var description = widget
                                      .place.wheelchairViableDescription!
                                      .toList()[i];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, left: 20, bottom: 5),
                                    child: Row(
                                      children: [
                                        description == 'Rampa de acesso'
                                            ? checkIcon
                                            : description ==
                                                    'Vaga de estacionamento'
                                                ? checkIcon
                                                : description == 'Elevador'
                                                    ? checkIcon
                                                    : description ==
                                                            'Banheiros adaptados'
                                                        ? checkIcon
                                                        : description ==
                                                                'Ambiente amplo'
                                                            ? checkIcon
                                                            : description ==
                                                                    'Sem rampa de acesso'
                                                                ? uncheckIcon
                                                                : description ==
                                                                        'Sem vagas de estacionamento'
                                                                    ? uncheckIcon
                                                                    : description ==
                                                                            'Sem elevador'
                                                                        ? uncheckIcon
                                                                        : description ==
                                                                                'Ambiente estrito'
                                                                            ? uncheckIcon
                                                                            : description == 'Banheiros não adaptados'
                                                                                ? uncheckIcon
                                                                                : const SizedBox(width: 6),
                                        Text(
                                          description,
                                          style: TextStyle(
                                              fontSize: fontSize == 0 ? 18 : 23,
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : null),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          //Barra Deficiente visual
                          //
                          GestureDetector(
                            onTap: () {
                              if (!blindIsVisible &&
                                  widget.place.blindViability != null) {
                                speak(
                                    "Para deficientes visuais, ${widget.place.name} é ${widget.place.blindViability == Viable.isViable ? 'Viável' : widget.place.blindViability == Viable.midViable ? 'Parcialmente viável' : 'Inviável'}, ele possui: ${widget.place.blindViableDescription.toString()}",
                                    isTts);
                              }
                              if (widget
                                  .place.blindViableDescription!.isNotEmpty) {
                                setState(() {
                                  blindIsVisible = !blindIsVisible;
                                });
                              }
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: 55,
                                  top: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: widget.place.blindViability ==
                                                Viable.isViable
                                            ? Colors.green[600]
                                            : widget.place.blindViability ==
                                                    Viable.midViable
                                                ? Colors.yellow[800]
                                                : widget.place.blindViability ==
                                                        Viable.isNotViable
                                                    ? Colors.red[600]
                                                    : Colors.grey[600],
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(15))),
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 10),
                                    child: const Text(
                                      'Deficiente visual',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Card(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(15),
                                              bottomRight:
                                                  Radius.circular(15))),
                                      elevation: 8,
                                      margin: const EdgeInsets.only(
                                          left: 50, right: 25, top: 4),
                                      color: widget.place.blindViability ==
                                              Viable.isViable
                                          ? Colors.green
                                          : widget.place.blindViability ==
                                                  Viable.midViable
                                              ? Colors.yellow[700]
                                              : widget.place.blindViability ==
                                                      Viable.isNotViable
                                                  ? Colors.red
                                                  : Colors.grey,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 7),
                                        child: Text(
                                          widget.place.blindViability ==
                                                  Viable.isViable
                                              ? 'Viável'
                                              : widget.place.blindViability ==
                                                      Viable.midViable
                                                  ? 'Parcialmente viável'
                                                  : widget.place
                                                              .blindViability ==
                                                          Viable.isNotViable
                                                      ? 'Inviável'
                                                      : 'Sem informações',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: fontSize == 0 ? 20 : 25,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 20,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: widget.place.blindViability ==
                                              Viable.isViable
                                          ? Colors.green[600]
                                          : widget.place.blindViability ==
                                                  Viable.midViable
                                              ? Colors.yellow[800]
                                              : widget.place.blindViability ==
                                                      Viable.isNotViable
                                                  ? Colors.red[600]
                                                  : Colors.grey[600],
                                    ),
                                    width: 60,
                                    height: 60,
                                    child: const Icon(
                                      Icons.blind,
                                      color: Colors.white,
                                      size: 45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //Descrição Deficiente visual
                          //
                          Visibility(
                            visible: blindIsVisible,
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 25, right: 25, top: 25),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: isDarkMode
                                          ? Colors.grey[800]!
                                          : Colors.black)),
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: widget
                                        .place.blindViableDescription?.length ??
                                    0,
                                itemBuilder: (ctx, i) {
                                  var description = widget
                                      .place.blindViableDescription!
                                      .toList()[i];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, left: 20, bottom: 5),
                                    child: Row(
                                      children: [
                                        description == 'Guia'
                                            ? checkIcon
                                            : description ==
                                                    'Informações em Braille'
                                                ? checkIcon
                                                : description == 'Piso tátil'
                                                    ? checkIcon
                                                    : description ==
                                                            'Guia (Sem manutenção)'
                                                        ? warningIcon
                                                        : description ==
                                                                'Sem guias'
                                                            ? uncheckIcon
                                                            : description ==
                                                                    'Sem informações em Braille'
                                                                ? uncheckIcon
                                                                : description ==
                                                                        'Sem piso tátil'
                                                                    ? uncheckIcon
                                                                    : const SizedBox(
                                                                        width:
                                                                            6),
                                        Text(
                                          description,
                                          style: TextStyle(
                                              fontSize: fontSize == 0 ? 18 : 23,
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : null),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          //Barra Deficiente auditivo
                          //
                          GestureDetector(
                            onTap: () {
                              if (!deafIsVisible &&
                                  widget.place.deafViability != null) {
                                speak(
                                    "Para deficientes auditivos, ${widget.place.name} é ${widget.place.deafViability == Viable.isViable ? 'Viável' : widget.place.deafViability == Viable.midViable ? 'Parcialmente viável' : 'Inviável'}, ele possui: ${widget.place.deafViableDescription.toString()}",
                                    isTts);
                              }
                              if (widget
                                  .place.deafViableDescription!.isNotEmpty) {
                                setState(() {
                                  deafIsVisible = !deafIsVisible;
                                });
                              }
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: 55,
                                  top: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: widget.place.deafViability ==
                                                Viable.isViable
                                            ? Colors.green[600]
                                            : widget.place.deafViability ==
                                                    Viable.midViable
                                                ? Colors.yellow[800]
                                                : widget.place.deafViability ==
                                                        Viable.isNotViable
                                                    ? Colors.red[600]
                                                    : Colors.grey[600],
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(15))),
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 10),
                                    child: const Text(
                                      'Deficiente auditivo',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Card(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(15),
                                              bottomRight:
                                                  Radius.circular(15))),
                                      elevation: 8,
                                      margin: const EdgeInsets.only(
                                          left: 50, right: 25, top: 4),
                                      color: widget.place.deafViability ==
                                              Viable.isViable
                                          ? Colors.green
                                          : widget.place.deafViability ==
                                                  Viable.midViable
                                              ? Colors.yellow[700]
                                              : widget.place.deafViability ==
                                                      Viable.isNotViable
                                                  ? Colors.red
                                                  : Colors.grey,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 7),
                                        child: Text(
                                          widget.place.deafViability ==
                                                  Viable.isViable
                                              ? 'Viável'
                                              : widget.place.deafViability ==
                                                      Viable.midViable
                                                  ? 'Parcialmente viável'
                                                  : widget.place
                                                              .deafViability ==
                                                          Viable.isNotViable
                                                      ? 'Inviável'
                                                      : 'Sem informações',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: fontSize == 0 ? 20 : 25,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 20,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: widget.place.deafViability ==
                                              Viable.isViable
                                          ? Colors.green[600]
                                          : widget.place.deafViability ==
                                                  Viable.midViable
                                              ? Colors.yellow[800]
                                              : widget.place.deafViability ==
                                                      Viable.isNotViable
                                                  ? Colors.red[600]
                                                  : Colors.grey[600],
                                    ),
                                    width: 60,
                                    height: 60,
                                    child: const Icon(
                                      Icons.hearing_disabled,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //Descrição deficiente auditivo
                          //
                          Visibility(
                            visible: deafIsVisible,
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 25, right: 25, top: 25),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: isDarkMode
                                          ? Colors.grey[800]!
                                          : Colors.black)),
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: widget
                                        .place.deafViableDescription?.length ??
                                    0,
                                itemBuilder: (ctx, i) {
                                  var description = widget
                                      .place.deafViableDescription!
                                      .toList()[i];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, left: 30, bottom: 5),
                                    child: Row(
                                      children: [
                                        description ==
                                                'Especialista em linguagem de sinais'
                                            ? checkIcon
                                            : description ==
                                                    'Nível de ruído adequado'
                                                ? checkIcon
                                                : description ==
                                                        'Sinalização adequada'
                                                    ? checkIcon
                                                    : description ==
                                                            'Pouca sinalização'
                                                        ? warningIcon
                                                        : description ==
                                                                'Nenhum especialista em linguagem de sinais'
                                                            ? uncheckIcon
                                                            : description ==
                                                                    'Nível de ruído inadequado'
                                                                ? uncheckIcon
                                                                : description ==
                                                                        'Sinalização ausente'
                                                                    ? uncheckIcon
                                                                    : const SizedBox(
                                                                        width:
                                                                            6),
                                        Flexible(
                                          child: Text(
                                            description,
                                            style: TextStyle(
                                                fontSize:
                                                    fontSize == 0 ? 18 : 23,
                                                fontWeight: FontWeight.w600,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : null),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: () {
                              speak(
                                  "Marque neste formulário, o que este local tem a oferecer",
                                  isTts);
                              openViabilityForm(context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.accessibility),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Avaliar viabilidade',
                                    style: TextStyle(
                                        fontSize: fontSize == 0 ? 20 : 25,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Divider(color: isDarkMode ? Colors.grey[800] : null),
                          const SizedBox(height: 10),
                          // Avaliações
                          //
                          Text(
                            'Avaliações',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: fontSize == 0 ? 20 : 25,
                                color: isDarkMode ? Colors.white : null),
                          ),
                          Text('Satisfação e comentários',
                              style: TextStyle(
                                  fontSize: fontSize == 0 ? 16 : 21,
                                  color: isDarkMode ? Colors.grey[400] : null)),
                          const SizedBox(height: 20),
                          // StreamBuilder
                          //
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('reviews')
                                  .doc(widget.place.id.toString())
                                  .collection('review')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return LoadingAnimationWidget.prograssiveDots(
                                    color:
                                        isDarkMode ? Colors.white : mainColor,
                                    size: 50,
                                  );
                                } else {
                                  final reviews = snapshot.data!.docs;

                                  if (reviews.isEmpty) {
                                    return Center(
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 60),
                                          Text(
                                            'O local ainda não possui avaliações.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize:
                                                    fontSize == 0 ? 20 : 25,
                                                fontWeight: FontWeight.w600,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : null),
                                          ),
                                          const SizedBox(height: 60),
                                        ],
                                      ),
                                    );
                                  }

                                  final allReviews = sortReviews(
                                    reviews
                                        .map((review) => review.data()
                                            as Map<String, dynamic>)
                                        .toList(),
                                    user!.uid,
                                  );

                                  int calculateAverageRating(
                                      List<DocumentSnapshot> reviews) {
                                    double totalRating = 0;

                                    for (var doc in reviews) {
                                      totalRating += doc['rating'];
                                    }

                                    double averageRating =
                                        totalRating / reviews.length;
                                    return averageRating.round();
                                  }

                                  int averageRating =
                                      calculateAverageRating(reviews);

                                  return Column(children: [
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        averageRating == 1
                                            ? const Icon(
                                                Icons
                                                    .sentiment_very_dissatisfied,
                                                color: Colors.red,
                                                size: 60,
                                              )
                                            : averageRating == 2
                                                ? const Icon(
                                                    Icons
                                                        .sentiment_dissatisfied,
                                                    color: Colors.redAccent,
                                                    size: 60,
                                                  )
                                                : averageRating == 3
                                                    ? const Icon(
                                                        Icons.sentiment_neutral,
                                                        color: Colors.amber,
                                                        size: 60,
                                                      )
                                                    : averageRating == 4
                                                        ? const Icon(
                                                            Icons
                                                                .sentiment_satisfied,
                                                            color: Colors
                                                                .lightGreen,
                                                            size: 60,
                                                          )
                                                        : const Icon(
                                                            Icons
                                                                .sentiment_very_satisfied,
                                                            color: Colors.green,
                                                            size: 60,
                                                          ),
                                        const SizedBox(width: 10),
                                        averageRating == 1
                                            ? Text(
                                                'Péssimo',
                                                style: TextStyle(
                                                    fontSize:
                                                        fontSize == 0 ? 25 : 30,
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : null,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            : averageRating == 2
                                                ? Text(
                                                    'Ruim',
                                                    style: TextStyle(
                                                        fontSize: fontSize == 0
                                                            ? 25
                                                            : 30,
                                                        color: isDarkMode
                                                            ? Colors.white
                                                            : null,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  )
                                                : averageRating == 3
                                                    ? Text(
                                                        'Medíocre',
                                                        style: TextStyle(
                                                            fontSize:
                                                                fontSize == 0
                                                                    ? 25
                                                                    : 30,
                                                            color: isDarkMode
                                                                ? Colors.white
                                                                : null,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      )
                                                    : averageRating == 4
                                                        ? Text(
                                                            'Bom',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    fontSize ==
                                                                            0
                                                                        ? 25
                                                                        : 30,
                                                                color: isDarkMode
                                                                    ? Colors
                                                                        .white
                                                                    : null,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          )
                                                        : Text(
                                                            'Ótimo',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    fontSize ==
                                                                            0
                                                                        ? 25
                                                                        : 30,
                                                                color: isDarkMode
                                                                    ? Colors
                                                                        .white
                                                                    : null,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          )
                                      ],
                                    ),
                                    const SizedBox(height: 40),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: allReviews.length,
                                      itemBuilder: (context, i) {
                                        final reviewData = allReviews[i];
                                        final userId = reviewData['id'];
                                        final userName = reviewData['name'];
                                        final comment = reviewData['comment'];
                                        final rating = reviewData['rating'];
                                        final image = reviewData['image'];

                                        bool isCurrentUserReview =
                                            userId == user!.uid;

                                        return Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color: isCurrentUserReview &
                                                          isDarkMode
                                                      ? Colors.grey[900]
                                                      : isCurrentUserReview
                                                          ? Colors.grey[200]
                                                          : null),
                                              child: ListTile(
                                                  leading: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            80),
                                                    child: CircleAvatar(
                                                        child: SizedBox(
                                                            height: 100,
                                                            width: 100,
                                                            child: Image.network(
                                                                image,
                                                                fit: BoxFit
                                                                    .cover))),
                                                  ),
                                                  title: Text(
                                                    userName,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: fontSize == 0 ? 18 : 23,
                                                        color: isDarkMode
                                                            ? Colors.grey[400]
                                                            : null),
                                                  ),
                                                  subtitle: Text(
                                                    comment,
                                                    style: TextStyle(
                                                        fontSize: fontSize == 0 ? 20 : 25,
                                                        color: isDarkMode
                                                            ? Colors.white
                                                            : null),
                                                  ),
                                                  trailing: rating == 1
                                                      ? const Icon(
                                                          Icons
                                                              .sentiment_very_dissatisfied,
                                                          color: Colors.red,
                                                          size: 35,
                                                        )
                                                      : rating == 2
                                                          ? const Icon(
                                                              Icons
                                                                  .sentiment_dissatisfied,
                                                              color: Colors
                                                                  .redAccent,
                                                              size: 35,
                                                            )
                                                          : rating == 3
                                                              ? const Icon(
                                                                  Icons
                                                                      .sentiment_neutral,
                                                                  color: Colors
                                                                      .amber,
                                                                  size: 35,
                                                                )
                                                              : rating == 4
                                                                  ? const Icon(
                                                                      Icons
                                                                          .sentiment_satisfied,
                                                                      color: Colors
                                                                          .lightGreen,
                                                                      size: 35,
                                                                    )
                                                                  : const Icon(
                                                                      Icons
                                                                          .sentiment_very_satisfied,
                                                                      color: Colors
                                                                          .green,
                                                                      size: 35,
                                                                    )),
                                            ),
                                            if (isCurrentUserReview)
                                              Positioned(
                                                right: 50,
                                                bottom: -15,
                                                child: SizedBox(
                                                  height: 35,
                                                  width: 50,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 1),
                                                        backgroundColor:
                                                            Colors.red,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50))),
                                                    onPressed: () async {
                                                      final bool
                                                          deleteConfirmed =
                                                          await showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return const DeleteDialog();
                                                        },
                                                      );
                                                      if (deleteConfirmed) {
                                                        speak(
                                                            "Sua avaliação foi removida.",
                                                            isTts);
                                                        deleteReview();
                                                      }
                                                    },
                                                    child: const Icon(
                                                        Icons.delete),
                                                  ),
                                                ),
                                              )
                                          ],
                                        );
                                      },
                                    ),
                                  ]);
                                }
                              }),
                          const SizedBox(height: 25),
                          if (!hasExistingReview)
                            WidgetRatingBar(
                                ratingCallback: ratingCallback,
                                commentCallback: commentCallback),
                          if (!hasExistingReview)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: ElevatedButton(
                                onPressed: () {
                                  speak("Sua avaliação foi publicada.", isTts);
                                  addReview();
                                  if (hasExistingReview == false) {
                                    hasExistingReview = true;
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: mainColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15))),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_reaction),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Enviar avaliação',
                                        style: TextStyle(
                                            fontSize: fontSize == 0 ? 20 : 25,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Botão Salvar/Criar rota
        //
        Positioned(
          top: -20,
          right: 15,
          child: SizedBox(
            width: 65,
            height: 65,
            child: Card(
              color: mainColor,
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: PopupMenuButton(
                  color: isDarkMode ? darkMainColor : null,
                  iconSize: 30,
                  elevation: 8,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: () {
                            speak(
                                widget.place.isFavorite
                                    ? 'Removido dos locais salvos.'
                                    : 'Adicionado aos locais salvos.',
                                isTts);
                            setState(() {
                              widget.place.toggleFavorite(favoritePlaces);
                            });
                            FloatingSnackBar(
                                message: widget.place.isFavorite
                                    ? 'Adicionado aos locais salvos.'
                                    : 'Removido dos locais salvos.',
                                context: context,
                                textStyle: const TextStyle(fontSize: 18));
                          },
                          child: Row(
                            children: [
                              Icon(
                                widget.place.isFavorite
                                    ? Icons.star
                                    : Icons.star_outline,
                                color: mainColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.place.isFavorite
                                    ? 'Remover local'
                                    : 'Salvar local',
                                style: TextStyle(
                                    fontSize: fontSize == 0 ? 20 : 25,
                                    color: isDarkMode ? Colors.white : null),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {},
                          child: Row(
                            children: [
                              const Icon(
                                Icons.route,
                                color: mainColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Criar rota',
                                style: TextStyle(
                                    fontSize: fontSize == 0 ? 20 : 25,
                                    color: isDarkMode ? Colors.white : null),
                              ),
                            ],
                          ),
                        ),
                      ]),
            ),
          ),
        ),
      ],
    );
  }
}
