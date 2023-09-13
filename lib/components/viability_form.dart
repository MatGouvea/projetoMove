import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_move/utils/constants.dart';
import 'package:provider/provider.dart';

import '../pages/settings_page.dart';

class ViabilityForm extends StatefulWidget {
  final int placeId;

  const ViabilityForm({super.key, required this.placeId});

  @override
  State<ViabilityForm> createState() => _ViabilityFormState();
}

class _ViabilityFormState extends State<ViabilityForm> {
  Map<String, bool> checkboxStates = {
    'Elevador': false,
    'Rampa de acesso': false,
    'Vaga de estacionamento para PcD': false,
    'Banheiros adaptados': false,
    'Ambiente espaçoso': false,
    'Guia': false,
    'Guia danificada': false,
    'Informações em Braille': false,
    'Piso tátil': false,
    'Especialista em linguagem de sinais': false,
    'Nível de ruído adequado no local': false,
    'Sinalização adequada': false,
    'Pouca sinalização': false
  };

  @override
  Widget build(BuildContext context) {
    Future<void> _sendDataToFirestore(Map<String, bool> data) async {
      final firestore = FirebaseFirestore.instance;

      final documentRef =
          firestore.collection('viability').doc(widget.placeId.toString());

      await documentRef.set(data);
    }

    final settings = Provider.of<SettingsPage>(context);
    final isDarkMode = settings.isDarkMode;
    final fontSize = settings.fontSize;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.all(30),
      color: isDarkMode ? darkMainColor : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Form(
          child: Column(
            children: [
              Text(
                'Avaliar viabilidade',
                style: TextStyle(
                    fontSize: fontSize == 0 ? 20 : 25,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : null),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text('Marque abaixo, o que este local oferece:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: fontSize == 0 ? 16 : 21,
                        color: isDarkMode ? Colors.grey[400] : null)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                            color: isDarkMode
                                ? secDarkMainColor
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Icon(
                              Icons.accessible_forward,
                              size: 40,
                              color: isDarkMode ? Colors.white : null,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Elevador',
                                  style: TextStyle(
                                      fontSize: fontSize == 0 ? 18 : 23,
                                      color: isDarkMode ? Colors.white : null),
                                ),
                                const SizedBox(width: 10),
                                Checkbox(
                                    activeColor: mainColor,
                                    value: checkboxStates['Elevador'] ?? false,
                                    onChanged: (value) {
                                      setState(() {
                                        checkboxStates['Elevador'] =
                                            value ?? false;
                                      });
                                    }),
                              ],
                            ),
                            SizedBox(height: fontSize == 0 ? 10 : 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rampa de acesso',
                                  style: TextStyle(
                                      fontSize: fontSize == 0 ? 18 : 23,
                                      color: isDarkMode ? Colors.white : null),
                                ),
                                const SizedBox(width: 10),
                                Checkbox(
                                    activeColor: mainColor,
                                    value: checkboxStates['Rampa de acesso'] ??
                                        false,
                                    onChanged: (value) {
                                      setState(() {
                                        checkboxStates['Rampa de acesso'] =
                                            value ?? false;
                                      });
                                    }),
                              ],
                            ),
                            SizedBox(height: fontSize == 0 ? 10 : 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Vaga de estacionamento para PcD',
                                    style: TextStyle(
                                        fontSize: fontSize == 0 ? 18 : 23,
                                        color:
                                            isDarkMode ? Colors.white : null),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Checkbox(
                                    activeColor: mainColor,
                                    value: checkboxStates[
                                            'Vaga de estacionamento para PcD'] ??
                                        false,
                                    onChanged: (value) {
                                      setState(() {
                                        checkboxStates[
                                                'Vaga de estacionamento para PcD'] =
                                            value ?? false;
                                      });
                                    }),
                              ],
                            ),
                            SizedBox(height: fontSize == 0 ? 10 : 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Banheiros adaptados',
                                  style: TextStyle(
                                      fontSize: fontSize == 0 ? 18 : 23,
                                      color: isDarkMode ? Colors.white : null),
                                ),
                                const SizedBox(width: 10),
                                Checkbox(
                                    activeColor: mainColor,
                                    value:
                                        checkboxStates['Banheiros adaptados'] ??
                                            false,
                                    onChanged: (value) {
                                      setState(() {
                                        checkboxStates['Banheiros adaptados'] =
                                            value ?? false;
                                      });
                                    }),
                              ],
                            ),
                            SizedBox(height: fontSize == 0 ? 10 : 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ambiente espaçoso',
                                  style: TextStyle(
                                      fontSize: fontSize == 0 ? 18 : 23,
                                      color: isDarkMode ? Colors.white : null),
                                ),
                                const SizedBox(width: 10),
                                Checkbox(
                                    activeColor: mainColor,
                                    value:
                                        checkboxStates['Ambiente espaçoso'] ??
                                            false,
                                    onChanged: (value) {
                                      setState(() {
                                        checkboxStates['Ambiente espaçoso'] =
                                            value ?? false;
                                      });
                                    }),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                            color: isDarkMode
                                ? secDarkMainColor
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Icon(
                              Icons.blind,
                              size: 40,
                              color: isDarkMode ? Colors.white : null,
                            ),
                            SizedBox(height: fontSize == 0 ? 10 : 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Guia',
                                  style: TextStyle(
                                      fontSize: fontSize == 0 ? 18 : 23,
                                      color: isDarkMode ? Colors.white : null),
                                ),
                                const SizedBox(width: 10),
                                Checkbox(
                                    activeColor: mainColor,
                                    value: checkboxStates['Guia'] ?? false,
                                    onChanged: (value) {
                                      setState(() {
                                        checkboxStates['Guia'] = value ?? false;
                                      });
                                    }),
                              ],
                            ),
                            SizedBox(height: fontSize == 0 ? 10 : 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Guia danificada',
                                  style: TextStyle(
                                      fontSize: fontSize == 0 ? 18 : 23,
                                      color: isDarkMode ? Colors.white : null),
                                ),
                                const SizedBox(width: 10),
                                Checkbox(
                                    activeColor: mainColor,
                                    value: checkboxStates['Guia danificada'] ??
                                        false,
                                    onChanged: (value) {
                                      setState(() {
                                        checkboxStates['Guia danificada'] =
                                            value ?? false;
                                      });
                                    }),
                              ],
                            ),
                            SizedBox(height: fontSize == 0 ? 10 : 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Informações em Braille',
                                    style: TextStyle(
                                        fontSize: fontSize == 0 ? 18 : 23,
                                        color: isDarkMode ? Colors.white : null),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Checkbox(
                                    activeColor: mainColor,
                                    value: checkboxStates[
                                            'Informações em Braille'] ??
                                        false,
                                    onChanged: (value) {
                                      setState(() {
                                        checkboxStates[
                                                'Informações em Braille'] =
                                            value ?? false;
                                      });
                                    }),
                              ],
                            ),
                            SizedBox(height: fontSize == 0 ? 10 : 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Piso tátil',
                                  style: TextStyle(
                                      fontSize: fontSize == 0 ? 18 : 23,
                                      color: isDarkMode ? Colors.white : null),
                                ),
                                const SizedBox(width: 10),
                                Checkbox(
                                    activeColor: mainColor,
                                    value:
                                        checkboxStates['Piso tátil'] ?? false,
                                    onChanged: (value) {
                                      setState(() {
                                        checkboxStates['Piso tátil'] =
                                            value ?? false;
                                      });
                                    }),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                            color: isDarkMode
                                ? secDarkMainColor
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Icon(
                              Icons.hearing_disabled,
                              size: 40,
                              color: isDarkMode ? Colors.white : null,
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Especialista em linguagem de sinais',
                                    style: TextStyle(
                                        fontSize: fontSize == 0 ? 18 : 23,
                                        color:
                                            isDarkMode ? Colors.white : null),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Checkbox(
                                    activeColor: mainColor,
                                    value: checkboxStates[
                                        'Especialista em linguagem de sinais']!,
                                    onChanged: (value) {
                                      setState(() {
                                        checkboxStates[
                                                'Especialista em linguagem de sinais'] =
                                            value!;
                                      });
                                    }),
                              ],
                            ),
                            SizedBox(height: fontSize == 0 ? 10 : 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Nível de ruído adequado no local',
                                    style: TextStyle(
                                        fontSize: fontSize == 0 ? 18 : 23,
                                        color:
                                            isDarkMode ? Colors.white : null),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Checkbox(
                                    activeColor: mainColor,
                                    value: checkboxStates[
                                        'Nível de ruído adequado no local']!,
                                    onChanged: (value) {
                                      setState(() {
                                        checkboxStates[
                                                'Nível de ruído adequado no local'] =
                                            value!;
                                      });
                                    }),
                              ],
                            ),
                            SizedBox(height: fontSize == 0 ? 10 : 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sinalização adequada',
                                  style: TextStyle(
                                      fontSize: fontSize == 0 ? 18 : 23,
                                      color: isDarkMode ? Colors.white : null),
                                ),
                                const SizedBox(width: 10),
                                Checkbox(
                                    activeColor: mainColor,
                                    value:
                                        checkboxStates['Sinalização adequada']!,
                                    onChanged: (value) {
                                      setState(() {
                                        checkboxStates['Sinalização adequada'] =
                                            value!;
                                      });
                                    }),
                              ],
                            ),
                            SizedBox(height: fontSize == 0 ? 10 : 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pouca sinalização',
                                  style: TextStyle(
                                      fontSize: fontSize == 0 ? 18 : 23,
                                      color: isDarkMode ? Colors.white : null),
                                ),
                                const SizedBox(width: 10),
                                Checkbox(
                                    activeColor: mainColor,
                                    value: checkboxStates['Pouca sinalização']!,
                                    onChanged: (value) {
                                      setState(() {
                                        checkboxStates['Pouca sinalização'] =
                                            value!;
                                      });
                                    }),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    _sendDataToFirestore(checkboxStates);
                    Navigator.of(context).pop();
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
                          'Enviar feedback',
                          style: TextStyle(
                              fontSize: fontSize == 0 ? 20 : 25,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close),
                        const SizedBox(width: 10),
                        Text(
                          'Cancelar',
                          style: TextStyle(
                              fontSize: fontSize == 0 ? 20 : 25,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
