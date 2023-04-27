import 'package:alpha_player_plugin_example/dem_simple_page.dart';
import 'package:flutter/material.dart';

import 'demo_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const DemoPage();
                      }));
                    },
                    child: const Text("AlphaPlayerView demo"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const DemoSimplePage();
                      }));
                    },
                    child: const Text("AlphaPlayerSimpleView demo"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
