import 'dart:async';

import 'package:ambilytics/ambilytics.dart' as ambylitics;
import 'package:ambilytics_example/preferences.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title, this.analyticsError});

  final String title;
  final Object? analyticsError;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const counterClicked = "counter_clicked";

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  bool errorShown = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
      ambylitics.sendEvent(name: counterClicked);
      // TODO, test in release mode what happens is predefined name is sent via Firebase
      //sendEvent('ad_click', null);

      debugPrint('$counterClicked sent');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!errorShown && widget.analyticsError != null) {
      Timer.run(() => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error initializing analytics'))));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // current date time
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: 100,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/color/red',
                    arguments: {'counter': _counter});
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(150, 50),
                backgroundColor: Colors.red[300],
              ),
              child: const Text('Go to Red'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/color/yellow',
                    arguments: {'counter': _counter});
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(150, 50),
                backgroundColor: Colors.yellow[300],
              ),
              child: const Text('Go to Yellow'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  routeSettings: const RouteSettings(name: '/modalDialog'),
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text("Modal dialog"),
                    content: const Text("Modal dialog showed"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(150, 50),
                backgroundColor: Colors.green[300],
              ),
              child: const Text('Show Dialog'),
            ),
            const SizedBox(
              height: 16,
            ),
            const ShareAnalyticsPreference()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
