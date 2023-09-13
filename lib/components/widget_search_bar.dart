import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:projeto_move/utils/constants.dart';
import 'package:provider/provider.dart';
import '../pages/settings_page.dart';
import 'map_controller_holder.dart';
import '../utils/.env';

class WidgetSearchBar extends StatefulWidget {
  const WidgetSearchBar({super.key});

  @override
  State<WidgetSearchBar> createState() => _WidgetSearchBarState();
}

class _WidgetSearchBarState extends State<WidgetSearchBar> {
  final FocusNode _focusNode = FocusNode();
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
    final settings = Provider.of<SettingsPage>(context);
    final isDarkMode = settings.isDarkMode;
    final isTts = settings.isTts;
    final fontSize = settings.fontSize;
    return Positioned(
      //Stack com toda a SearchBar
      child: Stack(
        children: [
          //Barra de pesquisa
          Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
              topRight: Radius.circular(15),
              bottomRight: Radius.circular(15),
            )),
            padding: const EdgeInsets.only(left: 65, top: 2),
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 60, horizontal: 15),
            child: Material(
              color: isDarkMode ? secDarkMainColor : Colors.white,
              elevation: 8,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              child: TextField(
                focusNode: _focusNode,
                onTap: () async {
                  speak("Informe o local em que deseja ir", isTts);
                  _focusNode.unfocus();
                  var place = await PlacesAutocomplete.show(
                    backArrowIcon: const Icon(Icons.navigate_before),
                    textStyle: TextStyle(
                      fontSize: fontSize == 0 ? 20 : 25,
                    ),
                    textDecoration: InputDecoration(
                        hintStyle: TextStyle(
                            fontSize: fontSize == 0 ? 20 : 25,
                            color: isDarkMode ? Colors.white : null)),
                    hint: 'Para onde vai?',
                    overlayBorderRadius: BorderRadius.circular(15),
                    location: Location(
                        lat: -8.65962077744912, lng: -56.08921407073899),
                    language: 'pt-BR',
                    context: context,
                    apiKey: mapsApiKey,
                    mode: Mode.overlay,
                    types: [],
                    strictbounds: false,
                    components: [Component(Component.country, 'br')],
                  );

                  final plist = GoogleMapsPlaces(
                    apiKey: mapsApiKey,
                    apiHeaders: await const GoogleApiHeaders().getHeaders(),
                  );
                  String placeid = place!.placeId ?? "0";
                  final detail = await plist.getDetailsByPlaceId(placeid);
                  final geometry = detail.result.geometry!;
                  final lat = geometry.location.lat;
                  final lang = geometry.location.lng;
                  var newlatlang = LatLng(lat, lang);

                  MapControllerHolder.mapController.animateCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(
                          target: newlatlang, zoom: 16, tilt: 40)));
                },
                style: const TextStyle(fontSize: 20),
                cursorHeight: 20,
                autofocus: false,
                decoration: InputDecoration(
                    hintStyle: TextStyle(
                        fontSize: fontSize == 0 ? 20 : 25, color: isDarkMode ? Colors.white : null),
                    prefixIcon: const Icon(Icons.search),
                    prefixIconColor: Colors.grey,
                    border: InputBorder.none,
                    hintText: 'Para onde vai?'),
              ),
            ),
          ),
          //Bloco do menu
          Positioned(
            top: 54,
            left: 18,
            child: Bounce(
              duration: const Duration(milliseconds: 100),
              onPressed: () {
                Scaffold.of(context).openDrawer();
                speak("Abrindo menu lateral", isTts);
              },
              child: Material(
                color: isDarkMode ? darkMainColor : null,
                elevation: 8,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: isDarkMode ? darkMainColor : Colors.grey[200],
                  ),
                  height: 65,
                  width: 65,
                  child: Icon(
                    Icons.menu,
                    size: 40,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
