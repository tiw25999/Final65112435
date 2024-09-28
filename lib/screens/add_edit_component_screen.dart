import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // นำเข้า ImagePicker

import '../helpers/database_helper.dart';

class AddEditComponentScreen extends StatefulWidget {
  final int plantID;
  final String plantName;
  final Map<String, dynamic>? component; // ใช้สำหรับแก้ไข component

  const AddEditComponentScreen({
    Key? key,
    required this.plantID,
    required this.plantName,
    this.component,
  }) : super(key: key);

  @override
  _AddEditComponentScreenState createState() => _AddEditComponentScreenState();
}

class _AddEditComponentScreenState extends State<AddEditComponentScreen> {
  final _componentNameController = TextEditingController();
  File? _componentIconFile;
  final ImagePicker _picker = ImagePicker(); // สร้างตัวแปรสำหรับ ImagePicker

  @override
  void initState() {
    super.initState();

    // หากมีข้อมูล component (แก้ไข) ก็ให้แสดงข้อมูลนั้น
    if (widget.component != null) {
      // ตรวจสอบและกำหนดค่า componentName
      _componentNameController.text = widget.component!['componentName'] ?? '';

      // ตรวจสอบและกำหนดค่า componentIcon
      if (widget.component!['componentIcon'] != null &&
          widget.component!['componentIcon'] is String &&
          widget.component!['componentIcon'] != '') {
        _componentIconFile = File(widget.component!['componentIcon']);
      }
    }
  }

  // ฟังก์ชันสำหรับเลือกภาพจากเครื่อง
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _componentIconFile = File(pickedFile.path); // บันทึกภาพที่เลือก
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  void _saveComponent() async {
    if (_componentNameController.text.isEmpty || _componentIconFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter component details and pick an icon'),
        ),
      );
      return;
    }

    final component = {
      'componentName': _componentNameController.text,
      'componentIcon': _componentIconFile!.path, // บันทึก path ของภาพ
      'plantID': widget.plantID, // ใช้ plantID จากคอนสตรัคเตอร์
    };

    // ตรวจสอบว่าเป็นการแก้ไขหรือเพิ่มใหม่
    if (widget.component == null) {
      // เพิ่มใหม่
      await DatabaseHelper.instance.insertComponent(component);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Component added for plant ${widget.plantName}')),
      );
    } else {
      // แก้ไข
      await DatabaseHelper.instance.updateComponent(
        widget.component!['componentID'],
        component,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Component updated for plant ${widget.plantName}')),
      );
    }

    Navigator.pop(context, true); // ปิดหน้าจอและส่งค่ากลับ
  }

  @override
  void dispose() {
    _componentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.component == null
            ? 'Add Component'
            : 'Edit Component'), // แสดงเป็น "Edit Component" เมื่อแก้ไข
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
              controller: _componentNameController,
              decoration: const InputDecoration(labelText: 'Component Name'),
            ),
            const SizedBox(height: 20),
            _componentIconFile == null
                ? const Text('No icon selected.')
                : Image.file(
                    _componentIconFile!,
                    width: 100,
                    height: 100,
                  ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Icon Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveComponent,
              child: Text(widget.component == null
                  ? 'Save Component'
                  : 'Update Component'), // เปลี่ยนข้อความปุ่ม
            ),
          ],
        ),
      ),
    );
  }
}
