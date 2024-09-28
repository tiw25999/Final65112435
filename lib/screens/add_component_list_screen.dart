import 'dart:io';

import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import 'add_edit_component_screen.dart'; // นำเข้าไฟล์สำหรับแก้ไขข้อมูล

class AddComponentListScreen extends StatefulWidget {
  final int plantID;
  final String plantName;

  const AddComponentListScreen(
      {Key? key, required this.plantID, required this.plantName})
      : super(key: key);

  @override
  _AddComponentListScreenState createState() => _AddComponentListScreenState();
}

class _AddComponentListScreenState extends State<AddComponentListScreen> {
  List<Map<String, dynamic>> _components = [];

  @override
  void initState() {
    super.initState();
    _loadComponents();
  }

  Future<void> _loadComponents() async {
    final components =
        await DatabaseHelper.instance.queryComponentsByPlantID(widget.plantID);
    setState(() {
      _components = components;
    });
  }

  void _editComponent(Map<String, dynamic> component) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditComponentScreen(
          component: component,
          plantID: widget.plantID, // ส่ง plantID ไปพร้อมกับ component
          plantName: widget.plantName, // ส่ง plantName ไปด้วย
        ),
      ),
    );
    if (result == true) {
      _loadComponents(); // โหลดข้อมูลใหม่หลังจากแก้ไข
    }
  }

  void _deleteComponent(int componentID) async {
    await DatabaseHelper.instance.deleteComponent(componentID);
    _loadComponents();
  }

  void _showOptions(Map<String, dynamic> component) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editComponent(component); // เรียกฟังก์ชันแก้ไข
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteComponent(component['componentID']); // ลบ component
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Components'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.plantName, // แสดงชื่อพรรณไม้ที่เลือก
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _components.isEmpty
                ? const Center(child: Text('No components found'))
                : ListView.builder(
                    itemCount: _components.length,
                    itemBuilder: (context, index) {
                      final component = _components[index];
                      return ListTile(
                        leading: (component['componentIcon'] != null &&
                                File(component['componentIcon']).existsSync())
                            ? Image.file(File(component['componentIcon']))
                            : const Icon(Icons.extension),
                        title: Text(component['componentName'] ?? 'No Name'),
                        onLongPress: () {
                          _showOptions(component); // กดค้างเพื่อแสดงตัวเลือก
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
