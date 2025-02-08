import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String email = '';
  String name = '';  // ใช้ 'name' แสดงข้อมูล first_name
  String errorMessage = '';
  File? _profileImage;
  TextEditingController passwordController = TextEditingController();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchProfile() async {
    String? token = await getToken();

    if (token == null || token.isEmpty) {
      setState(() {
        errorMessage = 'No token provided';
      });
      return;
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        email = data['email'];
        name = data['first_name'];  // แก้ไขจาก 'name' เป็น 'first_name'
        errorMessage = '';
      });
    } else {
      setState(() {
        errorMessage = 'Failed to fetch profile: ${response.body}';
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      uploadProfileImage();
    }
  }

  Future<void> uploadProfileImage() async {
    String? token = await getToken();

    if (token == null || token.isEmpty) {
      setState(() {
        errorMessage = 'No token provided';
      });
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:3000/upload_profile'));
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(await http.MultipartFile.fromPath('file', _profileImage!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        errorMessage = 'Profile image updated successfully';
      });
    } else {
      setState(() {
        errorMessage = 'Failed to upload profile image';
      });
    }
  }

  Future<void> changePassword() async {
    String? token = await getToken();

    if (token == null || token.isEmpty) {
      setState(() {
        errorMessage = 'No token provided';
      });
      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/change-password'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode({
        'new_password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        errorMessage = 'Password changed successfully';
      });
    } else {
      setState(() {
        errorMessage = 'Failed to change password';
      });
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // กลับไปหน้าก่อนหน้า
          },
        ),
        title: Text("Profile"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade300, Colors.orange.shade100],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : AssetImage('assets/default_avatar.png') as ImageProvider,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.4),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    name,  // ใช้ 'first_name' ที่ดึงจาก API
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Account'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('Password'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Change Password'),
                          content: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(hintText: 'Enter new password'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                changePassword();
                                Navigator.pop(context);
                              },
                              child: Text('Change'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text("Logout"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
