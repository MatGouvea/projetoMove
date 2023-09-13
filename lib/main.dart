import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto_move/components/is_recent_list.dart';
import 'package:projeto_move/components/marker_manager.dart';
import 'package:projeto_move/pages/forgot_password_page.dart';
import 'package:projeto_move/pages/settings_page.dart';
import 'package:projeto_move/pages/recent_places_page.dart';
import 'package:projeto_move/utils/app_routes.dart';
import 'package:provider/provider.dart';
import 'components/favorite_list.dart';
import 'pages/auth_or_app_page.dart';
import 'pages/favorite_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsPage(),
        ),
        ChangeNotifierProvider(
          create: (_) => IsRecentList(),
        ),
        ChangeNotifierProvider(
          create: (_) => MarkerManager(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoriteList(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Move!',
        theme: ThemeData(
          fontFamily: 'OpenSans',
        ),
        routes: {
          AppRoutes.authOrHome: (ctx) => const AuthOrAppPage(),
          AppRoutes.recentPlacesPage: (ctx) => const RecentPlacesPage(),
          AppRoutes.favoritePage: (ctx) => const FavoritePage(),
          AppRoutes.settingsPage: (ctx) => SettingsPage(),
          AppRoutes.forgotPasswordPage: (ctx) => ForgotPasswordPage()
        },
      ),
    );
  }
}
