import 'package:flutter/material.dart';
import 'profile_screen.dart';

import 'list.dart';
import 'cat.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_page.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2;
  List<dynamic> _posts = [];
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  // ดึงข้อมูลโพสต์จากเซิร์ฟเวอร์
  Future<void> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/postsa'));

      if (response.statusCode == 200) {
        setState(() {
          _posts = json.decode(response.body);  // อัปเดต _posts เมื่อได้รับข้อมูล
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (error) {
      print('Error fetching posts: $error');
    }
  }

  // ฟังก์ชันสำหรับเพิ่มโพสต์
  Future<void> addPost(Map<String, dynamic> newPost) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/posts'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(newPost),
      );

      if (response.statusCode == 201) {
        fetchPosts();  // รีเฟรชข้อมูลหลังจากเพิ่มโพสต์
      } else {
        throw Exception('Failed to add post');
      }
    } catch (error) {
      print('Error adding post: $error');
    }
  }

  // ฟังก์ชันสำหรับลบโพสต์
  Future<void> deletePost(String postId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/postsa/$postId'),
      );

      if (response.statusCode == 200) {
        fetchPosts();  // รีเฟรชข้อมูลหลังจากลบโพสต์
      } else {
        throw Exception('Failed to delete post');
      }
    } catch (error) {
      print('Error deleting post: $error');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Cat()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ListPage()),
      );
    } else if (index == 1) {
      // Refresh posts when the home icon is tapped
      fetchPosts();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,  // Align the icons to the right
                children: [
                  Icon(Icons.notifications, color: Colors.black),
                  SizedBox(width: 16.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      radius: 20.0,
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade500, Colors.red.shade700],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dogs And Cats",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Younger siblings and friends",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/5.png',
                      height: 80.0,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search Name",
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All Dogs And Cats",
                    style: TextStyle(color: Colors.black, fontSize: 18.0),
                  ),
                  Row(
                    children: [
                      _buildCategoryButton("All", _selectedCategory == "All"),
                      SizedBox(width: 8.0),
                      _buildCategoryButton("Dogs", _selectedCategory == "Dogs"),
                      SizedBox(width: 8.0),
                      _buildCategoryButton("Cats", _selectedCategory == "Cats"),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: _buildFilteredCustodianCards(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredCustodianCards() {
    // กรองข้อมูลโพสต์ที่มีประเภท Adopt ตามที่เลือก
    List<dynamic> filteredPosts = _selectedCategory == "All"
        ? _posts
        : _posts.where((post) => post['adopt'] != null && post['adopt'] == _selectedCategory).toList();

    // หากไม่มีข้อมูลที่ตรงกับการกรอง ให้แสดงข้อความแจ้งเตือน
    if (filteredPosts.isEmpty) {
      return [
        Center(child: Text("No posts found for this category.")),
      ];
    }

    // แสดงการ์ดแต่ละโพสต์ที่ผ่านการกรอง
    return filteredPosts.map((custodian) {
      return _buildCustodianCard(custodian);
    }).toList();
  }

  Widget _buildCustodianCard(Map<String, dynamic> custodian) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, size: 50, color: Colors.orange),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: ${custodian['name']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Age: ${custodian['age']}"),
                      Text("Gender: ${custodian['gender']}"),
                      Text("Adopt: ${custodian['adopt']}"),
                      Text("Phone: ${custodian['phone']}"),
                      Text("Price: ${custodian['price']}"),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // เพิ่มการนำทางไปยังหน้ารายละเอียดเพิ่มเติม
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(custodian: custodian),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: Text("เพิ่มเติม", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildCategoryButton(String category, bool isSelected) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.orange : Colors.grey[300], // Use backgroundColor instead of primary
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      ),
      child: Text(category),
    );
  }
}