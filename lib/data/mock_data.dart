import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:projeto_move/models/each_place.dart';

final detailedPlaces = [
  EachPlace(
      id: 0,
      name: 'Fatec Taubaté',
      address:
          'Av. Tomé Portes Del Rei, 525 - Vila São José, Taubaté - SP, 12070-100',
      type: 'Educação Superior',
      icon: Icons.school,
      images: [
        Image.asset('assets/images/mock_images/fatec_1.jpg'),
        Image.asset('assets/images/mock_images/fatec_2.jpg'),
        Image.asset('assets/images/mock_images/fatec_3.jpg'),
        Image.asset('assets/images/mock_images/fatec_4.jpg'),
        Image.asset('assets/images/mock_images/fatec_5.jpg'),
        Image.asset('assets/images/mock_images/fatec_6.jpg'),
        Image.asset('assets/images/mock_images/fatec_7.jpg'),
      ],
      wheelchairViability: Viable.isViable,
      blindViability: Viable.isNotViable,
      wheelchairViableDescription: wheelchairViableDescription
          .where((d) =>
              d == 'Rampa de acesso' ||
              d == 'Vaga de estacionamento' ||
              d == 'Elevador' ||
              d == 'Banheiros adaptados' ||
              d == 'Ambiente amplo')
          .toList(),
      blindViableDescription: blindViableDescription.where((d) =>
          d == 'Guia (Sem manutenção)' ||
          d == 'Sem piso tátil' ||
          d == 'Sem informações em Braille'),
      position: const LatLng(-23.012953276586597, -45.53634538815137)),
  //
  // 1
  EachPlace(
      id: 1,
      name: 'Terminal Rodoviário Velho',
      address:
          'Parque Dr. Barbosa de Oliveira, 34 - Centro, Taubaté - SP, 12020-190',
      type: 'Serviço de transporte',
      icon: Icons.directions_bus,
      images: [
        Image.asset('assets/images/mock_images/rodoviaria_1.jpg'),
        Image.asset('assets/images/mock_images/rodoviaria_2.jpg'),
      ],
      wheelchairViability: Viable.midViable,
      blindViability: Viable.midViable,
      deafViability: Viable.midViable,
      wheelchairViableDescription: wheelchairViableDescription
          .where((d) =>
              d == 'Rampa de acesso' ||
              d == 'Ambiente amplo' ||
              d == 'Sem elevador' ||
              d == 'Sem vagas de estacionamento' ||
              d == 'Banheiros não adaptados')
          .toList(),
      blindViableDescription: blindViableDescription.where((d) =>
          d == 'Guia' ||
          d == 'Sem informações em Braille' ||
          d == 'Sem piso tátil'),
      deafViableDescription: deafViableDescription.where((d) =>
          d == 'Sinalização adequada' ||
          d == 'Nível de ruído inadequado' ||
          d == 'Nenhum especialista em linguagem de sinais'),
      position: const LatLng(-23.022624831792577, -45.55927886023051)),
  //
  // 2
  EachPlace(
      id: 2,
      name: 'Ótica Golden Mix',
      address: 'Praça Dom Epaminondas, 47 - Centro, Taubaté - SP, 12010-020',
      type: 'Ótica',
      icon: Icons.shopping_cart,
      images: [
        Image.asset('assets/images/mock_images/goldenmix_1.JPG'),
        Image.asset('assets/images/mock_images/goldenmix_2.jpg'),
        Image.asset('assets/images/mock_images/goldenmix_3.jpg'),
      ],
      wheelchairViability: Viable.isViable,
      blindViability: Viable.midViable,
      deafViability: Viable.isViable,
      wheelchairViableDescription: wheelchairViableDescription
          .where((d) =>
              d == 'Rampa de acesso' ||
              d == 'Ambiente amplo' ||
              d == 'Sem elevador' ||
              d == 'Sem vagas de estacionamento' ||
              d == 'Banheiros adaptados')
          .toList(),
      blindViableDescription: blindViableDescription.where((d) =>
          d == 'Guia' ||
          d == 'Sem informações em Braille' ||
          d == 'Sem piso tátil'),
      deafViableDescription: deafViableDescription.where((d) =>
          d == 'Sinalização adequada' ||
          d == 'Nível de ruído adequado' ||
          d == 'Nenhum especialista em linguagem de sinais'),
      position: const LatLng(-23.026163899999993, -45.55576640731722)),
  //
  //3
  EachPlace(
      id: 3,
      name: 'Café Chicão',
      address: 'R. Jacques Felix, 470 - Centro, Taubaté - SP, 12020-060',
      type: 'Cafeteria',
      icon: Icons.coffee_maker,
      images: [
        Image.asset('assets/images/mock_images/cafechicao_1.JPG'),
        Image.asset('assets/images/mock_images/cafechicao_2.JPG'),
        Image.asset('assets/images/mock_images/cafechicao_3.JPG'),
        Image.asset('assets/images/mock_images/cafechicao_4.JPG'),
      ],
      wheelchairViability: Viable.isNotViable,
      blindViability: Viable.midViable,
      deafViability: Viable.isNotViable,
      wheelchairViableDescription: wheelchairViableDescription
          .where((d) =>
              d == 'Sem rampa de acesso' ||
              d == 'Ambiente estrito' ||
              d == 'Sem elevador' ||
              d == 'Sem vagas de estacionamento' ||
              d == 'Banheiros não adaptados')
          .toList(),
      blindViableDescription: blindViableDescription.where((d) =>
          d == 'Guia' ||
          d == 'Sem informações em Braille' ||
          d == 'Sem piso tátil'),
      deafViableDescription: deafViableDescription.where((d) =>
          d == 'Pouca sinalização' ||
          d == 'Nível de ruído inadequado' ||
          d == 'Nenhum especialista em linguagem de sinais'),
      position: const LatLng(-23.02438891131926, -45.55474774122327)),
  //
  //4
  EachPlace(
      id: 4,
      name: 'Boulevard Rio Branco',
      address: 'R. Visc. do Rio Branco, 179 - Centro, Taubaté - SP, 12020-040',
      type: 'Shopping center',
      icon: Icons.shopping_bag,
      images: [
        Image.asset('assets/images/mock_images/boulevard_1.JPG'),
        Image.asset('assets/images/mock_images/boulevard_2.JPG'),
      ],
      wheelchairViability: Viable.isViable,
      blindViability: Viable.isNotViable,
      deafViability: Viable.isViable,
      wheelchairViableDescription: wheelchairViableDescription
          .where((d) =>
              d == 'Rampa de acesso' ||
              d == 'Ambiente amplo' ||
              d == 'Elevador' ||
              d == 'Sem vagas de estacionamento' ||
              d == 'Banheiros não adaptados')
          .toList(),
      blindViableDescription: blindViableDescription.where((d) =>
          d == 'Sem guias' ||
          d == 'Sem informações em Braille' ||
          d == 'Sem piso tátil'),
      deafViableDescription: deafViableDescription.where((d) =>
          d == 'Sinalização adequada' ||
          d == 'Nível de ruído adequado' ||
          d == 'Nenhum especialista em linguagem de sinais'),
      position: const LatLng(-23.024687830804854, -45.554709904777305)),
  //
  //5
  EachPlace(
      id: 5,
      name: 'Drogaquinze',
      address: 'Praça Dom Epaminondas - Centro, Taubaté - SP, 12010-020',
      type: 'Empresa farmacêutica',
      icon: Icons.medication,
      images: [
        Image.asset('assets/images/mock_images/drogaquinze_1.JPG'),
        Image.asset('assets/images/mock_images/drogaquinze_2.JPG'),
      ],
      wheelchairViability: Viable.midViable,
      blindViability: Viable.isViable,
      deafViability: Viable.isViable,
      wheelchairViableDescription: wheelchairViableDescription
          .where((d) =>
              d == 'Rampa de acesso' ||
              d == 'Ambiente amplo' ||
              d == 'Sem elevador' ||
              d == 'Sem vagas de estacionamento' ||
              d == 'Banheiros não adaptados')
          .toList(),
      blindViableDescription: blindViableDescription.where((d) =>
          d == 'Guia' ||
          d == 'Informações em Braille' ||
          d == 'Sem piso tátil'),
      deafViableDescription: deafViableDescription.where((d) =>
          d == 'Sinalização adequada' ||
          d == 'Nível de ruído adequado' ||
          d == 'Nenhum especialista em linguagem de sinais'),
      position: const LatLng(-23.026911003199682, -45.55502310879746)),
  //
  //6
  EachPlace(
      id: 6,
      name: 'Lojas Torra',
      address: 'R. Dona Chiquinha de Matos, 385 - Centro, Taubaté - SP, 12030-230',
      type: 'Loja de roupas',
      icon: Icons.shopping_bag,
      images: [
        Image.asset('assets/images/mock_images/torra_1.JPG'),
        Image.asset('assets/images/mock_images/torra_2.jpg'),
        Image.asset('assets/images/mock_images/torra_3.jpg'),
      ],
      wheelchairViability: Viable.isViable,
      blindViability: Viable.midViable,
      deafViability: Viable.isViable,
      wheelchairViableDescription: wheelchairViableDescription
          .where((d) =>
              d == 'Rampa de acesso' ||
              d == 'Ambiente amplo' ||
              d == 'Elevador' ||
              d == 'Sem vagas de estacionamento' ||
              d == 'Banheiros adaptados')
          .toList(),
      blindViableDescription: blindViableDescription.where((d) =>
          d == 'Guia' ||
          d == 'Sem informações em Braille' ||
          d == 'Sem piso tátil'),
      deafViableDescription: deafViableDescription.where((d) =>
          d == 'Sinalização adequada' ||
          d == 'Nível de ruído adequado' ||
          d == 'Especialista em linguagem de sinais'),
      position: const LatLng(-23.024981939003712, -45.55565112489212)),
  //
  //7
  EachPlace(
      id: 7,
      name: 'Jordânia e Mattos',
      address: 'R. Dr. Souza Alves, 312 - Centro, Taubaté - SP, 12020-030',
      type: 'Clínica',
      icon: Icons.emergency,
      images: [
        Image.asset('assets/images/mock_images/jordania_1.jpg'),
      ],
      wheelchairViability: Viable.midViable,
      blindViability: Viable.midViable,
      deafViability: Viable.isNotViable,
      wheelchairViableDescription: wheelchairViableDescription
          .where((d) =>
              d == 'Sem rampa de acesso' ||
              d == 'Ambiente estrito' ||
              d == 'Sem elevador' ||
              d == 'Vaga de estacionamento' ||
              d == 'Banheiros adaptados')
          .toList(),
      blindViableDescription: blindViableDescription.where((d) =>
          d == 'Guia' ||
          d == 'Sem informações em Braille' ||
          d == 'Sem piso tátil'),
      deafViableDescription: deafViableDescription.where((d) =>
          d == 'Sinalização ausente' ||
          d == 'Nível de ruído adequado' ||
          d == 'Nenhum especialista em linguagem de sinais'),
      position: const LatLng(-23.023182216558197, -45.554670388124656)),
  //
  //8
  EachPlace(
      id: 8,
      name: 'Caedu Moda',
      address: 'R. Visc. do Rio Branco, 217 - Centro, Taubaté - SP, 12020-040',
      type: 'Loja de roupas',
      icon: Icons.shopping_bag,
      images: [
        Image.asset('assets/images/mock_images/caedu_1.JPG'),
        Image.asset('assets/images/mock_images/caedu_2.jpg'),
      ],
      wheelchairViability: Viable.midViable,
      blindViability: Viable.midViable,
      deafViability: Viable.isViable,
      wheelchairViableDescription: wheelchairViableDescription
          .where((d) =>
              d == 'Sem rampa de acesso' ||
              d == 'Ambiente amplo' ||
              d == 'Elevador' ||
              d == 'Sem vagas de estacionamento' ||
              d == 'Banheiros adaptados')
          .toList(),
      blindViableDescription: blindViableDescription.where((d) =>
          d == 'Guia' ||
          d == 'Sem informações em Braille' ||
          d == 'Sem piso tátil'),
      deafViableDescription: deafViableDescription.where((d) =>
          d == 'Sinalização adequada' ||
          d == 'Nível de ruído inadequado' ||
          d == 'Especialista em linguagem de sinais'),
      position: const LatLng(-23.02489516365942, -45.55496028790236)),
  //
  //9
  EachPlace(
      id: 9,
      name: 'New Big Cosméticos',
      address: 'R. Visc. do Rio Branco, 232 - Centro, Taubaté - SP, 12020-040',
      type: 'Loja de cosméticos',
      icon: Icons.shopping_bag,
      images: [
        Image.asset('assets/images/mock_images/newbig_1.JPG'),
        Image.asset('assets/images/mock_images/newbig_2.jpg'),
        Image.asset('assets/images/mock_images/newbig_3.jpg'),
      ],
      wheelchairViability: Viable.isViable,
      blindViability: Viable.midViable,
      deafViability: Viable.isViable,
      wheelchairViableDescription: wheelchairViableDescription
          .where((d) =>
              d == 'Rampa de acesso' ||
              d == 'Ambiente amplo' ||
              d == 'Elevador' ||
              d == 'Sem vagas de estacionamento' ||
              d == 'Banheiros adaptados')
          .toList(),
      blindViableDescription: blindViableDescription.where((d) =>
          d == 'Guia' ||
          d == 'Sem informações em Braille' ||
          d == 'Sem piso tátil'),
      deafViableDescription: deafViableDescription.where((d) =>
          d == 'Sinalização adequada' ||
          d == 'Nível de ruído adequado' ||
          d == 'Especialista em linguagem de sinais'),
      position: const LatLng(-23.025058826813986, -45.55537221064327)),
  //
  //10
  EachPlace(
      id: 10,
      name: 'Americanas Express',
      address: 'R. Visc. do Rio Branco, 247 - Centro, Taubaté - SP, 12020-040',
      type: 'Loja de departamento',
      icon: Icons.shopping_bag,
      images: [
        Image.asset('assets/images/mock_images/americanas_1.jpg'),
        Image.asset('assets/images/mock_images/americanas_2.jpg'),
        Image.asset('assets/images/mock_images/americanas_3.jpg'),
      ],
      wheelchairViability: Viable.isNotViable,
      blindViability: Viable.isViable,
      deafViability: Viable.isViable,
      wheelchairViableDescription: wheelchairViableDescription
          .where((d) =>
              d == 'Rampa de acesso' ||
              d == 'Ambiente estrito' ||
              d == 'Sem elevador' ||
              d == 'Sem vagas de estacionamento' ||
              d == 'Banheiros não adaptados')
          .toList(),
      blindViableDescription: blindViableDescription.where((d) =>
          d == 'Guia' ||
          d == 'Informações em Braille' ||
          d == 'Piso tátil'),
      deafViableDescription: deafViableDescription.where((d) =>
          d == 'Sinalização adequada' ||
          d == 'Nível de ruído adequado' ||
          d == 'Especialista em linguagem de sinais'),
      position: const LatLng(-23.025206591133802, -45.55528669502774)),
  //
  //11
  EachPlace(
      id: 11,
      name: 'Tennisbar',
      address: 'R. Duque de Caxias, 292 - Centro, Taubaté - SP, 12020-050',
      type: 'Loja de calçados',
      icon: Icons.shopping_bag,
      images: [
        Image.asset('assets/images/mock_images/tennisbar_1.jpg'),
        Image.asset('assets/images/mock_images/tennisbar_2.jpg'),
        Image.asset('assets/images/mock_images/tennisbar_3.jpg'),
      ],
      wheelchairViability: Viable.midViable,
      blindViability: Viable.midViable,
      deafViability: Viable.midViable,
      wheelchairViableDescription: wheelchairViableDescription
          .where((d) =>
              d == 'Rampa de acesso' ||
              d == 'Ambiente amplo' ||
              d == 'Sem elevador' ||
              d == 'Sem vagas de estacionamento' ||
              d == 'Banheiros não adaptados')
          .toList(),
      blindViableDescription: blindViableDescription.where((d) =>
          d == 'Guia' ||
          d == 'Sem informações em Braille' ||
          d == 'Sem piso tátil'),
      deafViableDescription: deafViableDescription.where((d) =>
          d == 'Sinalização adequada' ||
          d == 'Nível de ruído adequado' ||
          d == 'Nenhum especialista em linguagem de sinais'),
      position: const LatLng(-23.02590999869277, -45.555141953695646)),
];

final List<String> wheelchairViableDescription = [
  'Rampa de acesso',
  'Vaga de estacionamento',
  'Elevador',
  'Banheiros adaptados',
  'Ambiente amplo',
  'Sem rampa de acesso',
  'Sem vagas de estacionamento',
  'Sem elevador',
  'Ambiente estrito',
  'Banheiros não adaptados'
];

final List<String> blindViableDescription = [
  'Guia',
  'Informações em Braille',
  'Piso tátil',
  'Guia (Sem manutenção)',
  'Sem guias',
  'Sem informações em Braille',
  'Sem piso tátil',
];

final List<String> deafViableDescription = [
  'Especialista em linguagem de sinais',
  'Nível de ruído adequado',
  'Sinalização adequada',
  'Pouca sinalização',
  'Nenhum especialista em linguagem de sinais',
  'Nível de ruído inadequado',
  'Sinalização ausente'
];
