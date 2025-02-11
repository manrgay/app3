import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> custodian;

  DetailPage({required this.custodian});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<dynamic> _comments = []; // รายการความคิดเห็น
  TextEditingController _nameController = TextEditingController();
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.custodian['id'] == null) {
      print('Error: post_id is null');
      return;
    }
    fetchComments(); // โหลดความคิดเห็นเมื่อเปิดหน้า
  }

  // ดึงความคิดเห็นจากเซิร์ฟเวอร์
  Future<void> fetchComments() async {
    String postId = widget.custodian['id'].toString();
    if (postId.isEmpty) {
      print('Error: post_id is empty');
      return;
    }

    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/comments?post_id=$postId'));

      if (response.statusCode == 200) {
        setState(() {
          _comments = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (error) {
      print('Error fetching comments: $error');
    }
  }

  // เพิ่มความคิดเห็น
  Future<void> addComment(String name, String comment) async {
    if (name.isEmpty || comment.isEmpty) return;

    final body = json.encode({
      'name': name,
      'comment': comment,
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/comments'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        _nameController.clear();
        _commentController.clear();
        fetchComments(); // รีเฟรชคอมเมนต์
      } else {
        throw Exception('Failed to add comment');
      }
    } catch (error) {
      print('Error adding comment: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    String postId = widget.custodian['id'].toString();
    if (postId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Error")),
        body: Center(child: Text('Post ID is missing or invalid')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("รายละเอียดเพิ่มเติม"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${widget.custodian['name']}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Age: ${widget.custodian['age']}"),
            Text("Gender: ${widget.custodian['gender']}"),
            Text("Adopt: ${widget.custodian['adopt']}"),
            Text("Phone: ${widget.custodian['phone']}"),
            Text("Price: ${widget.custodian['price']}"),
            SizedBox(height: 20),

            // แสดงรายการความคิดเห็น
            Expanded(
              child: _comments.isEmpty
                  ? Center(child: Text("ยังไม่มีความคิดเห็น"))
                  : ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _comments[index]['name'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 6),
                          Text(_comments[index]['comment']),
                          SizedBox(height: 6),
                          Text(
                            "โพสต์เมื่อ: ${_comments[index]['created_at']}",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 10),

            // ช่องป้อนชื่อและความคิดเห็น
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "ชื่อของคุณ",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "เพิ่มความคิดเห็น...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    addComment(_nameController.text, _commentController.text);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: Text("ส่ง"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
