import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';

class AddLandUseScreen extends StatefulWidget {
  final int plantID;
  final String plantName;

  const AddLandUseScreen({
    Key? key,
    required this.plantID,
    required this.plantName,
  }) : super(key: key);

  @override
  _AddLandUseScreenState createState() => _AddLandUseScreenState();
}

class _AddLandUseScreenState extends State<AddLandUseScreen> {
  final _landUseNameController = TextEditingController();
  final _landUseDescriptionController = TextEditingController();

  void _saveLandUse() async {
    if (_landUseNameController.text.isEmpty ||
        _landUseDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    final landUseType = {
      'LandUseTypeName': _landUseNameController.text,
      'LandUseTypeDescription': _landUseDescriptionController.text,
    };

    int landUseTypeID =
        await DatabaseHelper.instance.insertLandUseType(landUseType);
    await DatabaseHelper.instance
        .insertPlantLandUse(widget.plantID, landUseTypeID);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('เพิ่มข้อมูลการใช้ที่ดินสำเร็จ')),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _landUseNameController.dispose();
    _landUseDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มการใช้ที่ดิน'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              widget.plantName,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _landUseNameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _landUseDescriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveLandUse,
              child: const Text('บันทึกการใช้ที่ดิน'),
            ),
          ],
        ),
      ),
    );
  }
}
