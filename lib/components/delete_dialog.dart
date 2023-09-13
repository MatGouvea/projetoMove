import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:projeto_move/utils/constants.dart';
import 'package:provider/provider.dart';

import '../pages/settings_page.dart';

class DeleteDialog extends StatefulWidget {
  const DeleteDialog({super.key});

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
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
    speak('Confirme. deseja realmente remover??', isTts);
    return AlertDialog(
      title: Text(
        'Confirmar remoção',
        style: TextStyle(
          color: isDarkMode ? Colors.grey[400] : null,
          fontWeight: FontWeight.w400,
          fontSize: fontSize == 0 ? null : 20,
        ),
      ),
      content: Text(
        'Deseja realmente remover?',
        style: TextStyle(
          color: isDarkMode ? Colors.white : null,
          fontSize: fontSize == 0 ? null : 20,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: isDarkMode ? secDarkMainColor : null,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(
            'SIM',
            style: TextStyle(
              color: mainColor,
              fontWeight: FontWeight.w500,
              fontSize: fontSize == 0 ? null : 20,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(
            'CANCELAR',
            style: TextStyle(
              color: Colors.red[400],
              fontWeight: FontWeight.w500,
              fontSize: fontSize == 0 ? null : 20,
            ),
          ),
        ),
      ],
    );
  }
}
