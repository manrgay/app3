import 'package:flutter/material.dart';

class AvatarSelectionScreen extends StatelessWidget {
  final Function(String) onAvatarSelected;

  AvatarSelectionScreen({required this.onAvatarSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Avatar"),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,  // แสดง 4 คอลัมน์
          childAspectRatio: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 3,  // จำนวนอวตารที่ต้องการแสดง
        itemBuilder: (context, index) {
          // เริ่มจากรูปที่ 1 แทนที่จะเป็นรูปที่ 0
          String avatarPath = 'assets/images/avatar${index + 1}.png';  // เพิ่ม 1 ที่ index

          return GestureDetector(
            onTap: () {
              onAvatarSelected(avatarPath);  // ส่งอวตารที่เลือกกลับไปยังหน้าหลัก
              Navigator.pop(context);  // ปิดหน้าปัจจุบัน
            },
            child: Image.asset(avatarPath),
          );
        },
      ),
    );
  }
}
