import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/init_pairing_screen.dart';
import '../screens/scan_pairing_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const HomeScreen(),
    '/init': (context) => const InitPairingScreen(),
    '/scan': (context) => const ScanPairingScreen(),
  };
}