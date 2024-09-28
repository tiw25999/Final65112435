import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../helpers/database_helper.dart';

class AddEditPlantScreen extends StatefulWidget {
  final Map<String, dynamic>? plant;

  const AddEditPlantScreen({Key? key, this.plant}) : super(key: key);

  @override
  _AddEditPlantScreenState createState() => _AddEditPlantScreenState();
}

class _AddEditPlantScreenState extends State<AddEditPlantScreen> {
  final _nameController = TextEditingController();
  final _scientificNameController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.plant != null) {
      _nameController.text = widget.plant!['plantName'] ?? '';
      _scientificNameController.text = widget.plant!['plantScientific'] ?? '';
      if (widget.plant!['plantImage'] != null &&
          widget.plant!['plantImage'].isNotEmpty) {
        _imageFile = File(widget.plant!['plantImage']);
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  void _savePlant() async {
    if (_nameController.text.isEmpty || _imageFile == null) {
      return;
    }

    final plant = {
      'plantName': _nameController.text,
      'plantScientific': _scientificNameController.text,
      'plantImage': _imageFile!.path,
    };

    if (widget.plant == null) {
      await DatabaseHelper.instance.insertPlant(plant);
    } else {
      await DatabaseHelper.instance
          .updatePlant(widget.plant!['plantID'], plant);
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant == null ? 'Add Plant' : 'Edit Plant'),
      ),
      body: SingleChildScrollView(
        // เพิ่ม SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Plant Name'),
              ),
              TextField(
                controller: _scientificNameController,
                decoration: const InputDecoration(labelText: 'Scientific Name'),
              ),
              const SizedBox(height: 20),
              _imageFile == null
                  ? const Text('No image selected.')
                  : Image.file(_imageFile!),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              ElevatedButton(
                onPressed: _savePlant,
                child: const Text('Save Plant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
