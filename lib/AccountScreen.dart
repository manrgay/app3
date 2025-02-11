import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String email = '';
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';  // เพิ่ม field สำหรับ phone_number
  String gender = '';       // เพิ่ม field สำหรับ gender
  String errorMessage = '';
  bool isLoading = true;  // เพิ่มตัวแปรสำหรับการแสดงสถานะการโหลด

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ฟังก์ชันสำหรับดึงข้อมูลผู้ใช้จาก API
  Future<void> fetchAccountDetails() async {
    String? token = await getToken();

    if (token == null || token.isEmpty) {
      setState(() {
        errorMessage = 'No token provided';
        isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/account'),
      headers: {
        'Authorization': 'Bearer $token',  // ส่ง token ใน headers
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        email = data['email'];
        firstName = data['first_name'];
        lastName = data['last_name'];
        phoneNumber = data['phone_number'];  // ดึงข้อมูล phone_number
        gender = data['gender'];  // ดึงข้อมูล gender
        errorMessage = '';
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = 'Failed to fetch account details: ${response.statusCode}';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAccountDetails();  // ดึงข้อมูลเมื่อหน้าโหลด
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (isLoading)
                Center(child: CircularProgressIndicator())  // แสดงการโหลด
              else if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              if (!isLoading && errorMessage.isEmpty) ...[
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Email'),
                  subtitle: Text(email),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('First Name'),
                  subtitle: Text(firstName),
                ),
                ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Last Name'),
                  subtitle: Text(lastName),
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Phone Number'),
                  subtitle: Text(phoneNumber),
                ),
                ListTile(
                  leading: Icon(Icons.transgender),
                  title: Text('Gender'),
                  subtitle: Text(gender),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
