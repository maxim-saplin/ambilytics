import 'package:flutter/material.dart';

class ColorScreen extends StatelessWidget {
  const ColorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var route = ModalRoute.of(context);
    var color = (route?.settings.name ?? '').endsWith('red')
        ? Colors.red[300]
        : Colors.yellow[300];
    var routeParams = (route?.settings.arguments ?? {}) as Map<String, dynamic>;
    var counter = routeParams['counter'] as int;

    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        title: Text('${color.toString()} screen'),
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
              '$counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
