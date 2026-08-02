import 'package:flutter/material.dart';

void main() {
  runApp(const EvHealthApp());
}

class EvHealthApp extends StatelessWidget {
  const EvHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EV Health',
      home: AppLaunchScreen(),
    );
  }
}

class AppLaunchScreen extends StatelessWidget {
  const AppLaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EV Health')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Battery health reports'),
              SizedBox(height: 8),
              Text(
                'Clear battery insights, stored locally on your device.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
