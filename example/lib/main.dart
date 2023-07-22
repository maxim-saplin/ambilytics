import 'package:ambilytics/ambilytics.dart' as ambilytics;
import 'package:ambilytics_example/color_screen.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

void main() async {
  // Inits either Firebase Analytics (macOS, iOS, Android, Web) or GA4 Measurement Protocol, sends out app_launch event with current platform as param

  await ambilytics.initAnalytics();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: ambilytics.isAmbyliticsInitialized
          ? [
              ambilytics.AmbyliticsObserver(
                  // Track dialog routes pushed via showDialog()
                  routeFilter: ambilytics.anyRouteFilter,
                  alwaySendScreenViewCust: true)
            ]
          : [],
      routes: {
        '/': (context) => HomeScreen(
              title: 'Home',
              analyticsError: ambilytics.initError,
            ),
        '/color/red': (context) => const ColorScreen(),
        '/color/yellow': (context) => const ColorScreen()
      },
    );
  }
}
