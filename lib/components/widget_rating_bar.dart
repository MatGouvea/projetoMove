
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../pages/settings_page.dart';
import '../utils/constants.dart';

class WidgetRatingBar extends StatefulWidget {
  final Function(double) ratingCallback;
  final Function(String) commentCallback;
   
  const WidgetRatingBar({super.key, required this.ratingCallback, required this.commentCallback});

  @override
  State<WidgetRatingBar> createState() => _WidgetRatingBarState();
}

class _WidgetRatingBarState extends State<WidgetRatingBar> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsPage>(context);
    final isDarkMode = settings.isDarkMode;
    final fontSize = settings.fontSize;

    return Column(
      children: [
        RatingBar.builder(
            unratedColor: isDarkMode ? Colors.grey : null,
            itemPadding: const EdgeInsets.all(5),
            itemSize: 50,
            initialRating: 3,
            itemCount: 5,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return const Icon(
                    Icons.sentiment_very_dissatisfied,
                    color: Colors.red,
                  );
                case 1:
                  return const Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.redAccent,
                  );
                case 2:
                  return const Icon(
                    Icons.sentiment_neutral,
                    color: Colors.amber,
                  );
                case 3:
                  return const Icon(
                    Icons.sentiment_satisfied,
                    color: Colors.lightGreen,
                  );
                case 4:
                  return const Icon(
                    Icons.sentiment_very_satisfied,
                    color: Colors.green,
                  );
                default:
                  throw Exception('Ocorreu um erro.');
              }
            },
            onRatingUpdate: (userRating) {
              widget.ratingCallback(userRating);
            }),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDarkMode ? secDarkMainColor : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 200,
          child: TextField(
            onChanged: (comment){
              widget.commentCallback(comment);
            },
            cursorColor: mainColor,
            style: TextStyle(
                fontSize: 20, color: isDarkMode ? Colors.white : null),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: 'Dê sua opinião sobre o local..',
              border: InputBorder.none,
              hintStyle: TextStyle(
                  fontSize: fontSize == 0 ? 20 : 25, color: isDarkMode ? Colors.white : null),
            ),
          ),
        ),
        const SizedBox(height: 20)
      ],
    );
  }
}
