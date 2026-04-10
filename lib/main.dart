import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/routes.dart';

void main() {
  // S'assure que les widgets sont bien initialisés avant de lancer l'app
  // (très utile quand on utilise du stockage sécurisé ou la caméra juste après)
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AltoApp());
}

class AltoApp extends StatelessWidget {
  const AltoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alto - Always Together',
      debugShowCheckedModeBanner: false, // Enlève le petit bandeau "DEBUG" en haut à droite
      theme: AltoTheme.lightTheme, // Utilise le thème créé par le Membre 2
      initialRoute: '/', // Point de départ de l'application
      routes: AppRoutes.routes, // Utilise la map des routes créée par le Membre 1
    );
  }
}