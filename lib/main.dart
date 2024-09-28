import 'package:flutter/material.dart';

import 'screens/add_edit_plant_screen.dart';
import 'screens/plant_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Manager',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => PlantListScreen(),
        '/add': (context) => const AddEditPlantScreen(),
      },
    );
  }
}
