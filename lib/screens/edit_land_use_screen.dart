import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';

class EditLandUseScreen extends StatefulWidget {
  final int plantID;
  final String plantName;
  final Map<String, dynamic> landUse;

  const EditLandUseScreen({
    Key? key,
    required this.plantID,
    required this.plantName,
    required this.landUse,
  }) : super(key: key);

  @override
  _EditLandUseScreenState createState() => _EditLandUseScreenState();
}

class _EditLandUseScreenState extends State<EditLandUseScreen> {
  final _landUseNameController = TextEditingController();
  final _landUseDescriptionController = TextEditingController();
  late int _landUseTypeID;

  @override
  void initState() {
    super.initState();

    // ตรวจสอบว่า landUse มีข้อมูลหรือไม่
    if (widget.landUse.isNotEmpty) {
      _landUseTypeID = widget.landUse['LandUseTypeID'] ??
          0; // ตั้งค่าเริ่มต้นเป็น 0 ถ้าเป็น null
      _landUseNameController.text = widget.landUse['LandUseTypeName'] ?? '';
      _landUseDescriptionController.text =
          widget.landUse['LandUseTypeDescription'] ?? '';
    } else {
      // ถ้า landUse ไม่มีข้อมูล ให้แสดงข้อความเตือน
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบข้อมูลการใช้ที่ดิน')),
      );
      Navigator.pop(context); // ปิดหน้าจอถ้าไม่มีข้อมูล
    }
  }

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

    await DatabaseHelper.instance.updateLandUseType(
      _landUseTypeID,
      landUseType,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('แก้ไขข้อมูลการใช้ที่ดินสำเร็จ')),
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
        title: const Text('แก้ไขการใช้ที่ดิน'),
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
              child: const Text('แก้ไขข้อมูลการใช้ที่ดิน'),
            ),
          ],
        ),
      ),
    );
  }
}
