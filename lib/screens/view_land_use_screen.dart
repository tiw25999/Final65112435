import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import 'edit_land_use_screen.dart';

class ViewLandUseScreen extends StatelessWidget {
  final int plantID;
  final String plantName;

  const ViewLandUseScreen({
    Key? key,
    required this.plantID,
    required this.plantName,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchLandUseData() async {
    return await DatabaseHelper.instance.queryLandUseByPlantID(plantID);
  }

  void _editLandUse(BuildContext context, Map<String, dynamic> landUse) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditLandUseScreen(
          landUse: landUse, // ส่งข้อมูล landUse สำหรับการแก้ไข
          plantID: plantID,
          plantName: plantName,
        ),
      ),
    );
    if (result == true) {
      _fetchLandUseData(); // โหลดข้อมูลใหม่ถ้าการแก้ไขสำเร็จ
    }
  }

  void _deleteLandUse(BuildContext context, int landUseID) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณแน่ใจว่าต้องการลบการใช้ที่ดินนี้?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (result == true) {
      await DatabaseHelper.instance.deleteLandUse(landUseID);
      _fetchLandUseData(); // รีเฟรชข้อมูลหลังจากลบ
    }
  }

  void _showOptions(BuildContext context, Map<String, dynamic> landUse) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('แก้ไข'),
              onTap: () {
                Navigator.pop(context);
                _editLandUse(context, landUse);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('ลบ'),
              onTap: () {
                Navigator.pop(context);
                // ตรวจสอบว่ามี LandUseTypeID หรือไม่
                if (landUse['LandUseTypeID'] != null) {
                  _deleteLandUse(context, landUse['LandUseTypeID']);
                } else {
                  // แสดงข้อความเตือนว่ามี ID ไม่ถูกต้อง
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('ID ของการใช้ที่ดินไม่ถูกต้อง')),
                  );
                }
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
        title: const Text('Land Use'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchLandUseData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาดในการดึงข้อมูล'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่พบข้อมูลการใช้ที่ดิน'));
          } else {
            final landUseData = snapshot.data!;
            return ListView.builder(
              itemCount: landUseData.length,
              itemBuilder: (context, index) {
                final landUse = landUseData[index];
                return ListTile(
                  title: Text(landUse['LandUseTypeName']),
                  subtitle: Text(landUse['LandUseTypeDescription']),
                  onLongPress: () {
                    _showOptions(context, landUse);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
