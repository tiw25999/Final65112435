import 'dart:io';

import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import 'add_component_list_screen.dart';
import 'add_edit_component_screen.dart';
import 'add_edit_plant_screen.dart';
import 'add_land_use_screen.dart';
import 'view_land_use_screen.dart';

class PlantListScreen extends StatefulWidget {
  const PlantListScreen({super.key});

  @override
  _PlantListScreenState createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  List<Map<String, dynamic>> _plants = [];
  List<Map<String, dynamic>> _filteredPlants = []; // รายการสำหรับการค้นหา
  String _searchQuery = ''; // ตัวแปรสำหรับการเก็บข้อความค้นหา

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    final plants = await DatabaseHelper.instance.queryAllPlants();
    setState(() {
      _plants = plants;
      _filteredPlants = plants; // เริ่มต้นให้ _filteredPlants เป็น _plants
    });
  }

  void _deletePlant(int plantID) async {
    await DatabaseHelper.instance.deletePlant(plantID);
    _loadPlants();
  }

  void _filterPlants(String query) {
    setState(() {
      _searchQuery = query; // เก็บค่าที่ค้นหา
      _filteredPlants = _plants.where((plant) {
        final plantName = plant['plantName'].toLowerCase();
        return plantName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('พรรณไม้'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'ค้นหาพรรณไม้',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // ขอบกลม
                  borderSide: const BorderSide(color: Colors.grey), // สีของขอบ
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // ขอบกลมเมื่อเลือก
                  borderSide: const BorderSide(
                      color: Colors.blue), // สีของขอบเมื่อเลือก
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(30.0), // ขอบกลมเมื่อเปิดใช้งาน
                  borderSide: const BorderSide(
                      color: Colors.grey), // สีของขอบเมื่อเปิดใช้งาน
                ),
              ),
              onChanged: _filterPlants, // ใช้สำหรับค้นหา
            ),
          ),
          Expanded(
            child: _filteredPlants.isEmpty
                ? const Center(child: Text('ไม่พบพรรณไม้'))
                : ListView.builder(
                    itemCount: _filteredPlants.length,
                    itemBuilder: (context, index) {
                      final plant = _filteredPlants[index];
                      return ListTile(
                        leading: (plant['plantImage'] != null &&
                                File(plant['plantImage']).existsSync())
                            ? Image.file(File(plant['plantImage']),
                                width: 50, height: 50)
                            : const Icon(Icons.image),
                        title: Text(plant['plantName'] ?? 'No Name'),
                        subtitle: Text(
                            plant['plantScientific'] ?? 'No scientific name'),
                        onTap: () {
                          _showViewOptions(plant);
                        },
                        onLongPress: () {
                          _showDeletePopupMenu(plant);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showViewOptions(Map<String, dynamic> plant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.extension),
                title: const Text('View Components'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddComponentListScreen(
                        plantID: plant['plantID'],
                        plantName: plant['plantName'],
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_list),
                title: const Text('View Land Use'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewLandUseScreen(
                        plantID: plant['plantID'],
                        plantName: plant['plantName'],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeletePopupMenu(Map<String, dynamic> plant) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deletePlant(plant['plantID']);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.local_florist),
              title: const Text('Add Plant'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddEditPlantScreen()),
                ).then((value) {
                  if (value == true) {
                    _loadPlants();
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add Plant Component'),
              onTap: () {
                Navigator.pop(context);
                _showPlantSelectionDialogForComponent();
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_location_alt),
              title: const Text('Add Land Use'),
              onTap: () {
                Navigator.pop(context);
                _showPlantSelectionDialogForLandUse();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPlantSelectionDialogForComponent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Plant to Add Component'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _plants.length,
              itemBuilder: (context, index) {
                final plant = _plants[index];
                return ListTile(
                  leading: (plant['plantImage'] != null &&
                          File(plant['plantImage']).existsSync())
                      ? Image.file(File(plant['plantImage']),
                          width: 50, height: 50)
                      : const Icon(Icons.image),
                  title: Text(plant['plantName'] ?? 'No Name'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditComponentScreen(
                          plantID: plant['plantID'],
                          plantName: plant['plantName'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showPlantSelectionDialogForLandUse() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Plant to Add Land Use'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _plants.length,
              itemBuilder: (context, index) {
                final plant = _plants[index];
                return ListTile(
                  leading: (plant['plantImage'] != null &&
                          File(plant['plantImage']).existsSync())
                      ? Image.file(File(plant['plantImage']),
                          width: 50, height: 50)
                      : const Icon(Icons.image),
                  title: Text(plant['plantName'] ?? 'No Name'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddLandUseScreen(
                          plantID: plant['plantID'],
                          plantName: plant['plantName'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
