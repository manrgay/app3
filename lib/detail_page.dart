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
  List<dynamic> _comments = [];
  TextEditingController _nameController = TextEditingController();
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/comments/${widget.custodian['id']}'));
      if (response.statusCode == 200) {
        setState(() {
          _comments = json.decode(utf8.decode(response.bodyBytes)); // ✅ รองรับภาษาไทย
        });
      }
    } catch (error) {
      print('Error fetching comments: $error');
    }
  }

  Future<void> addComment(String name, String comment) async {
    if (name.isEmpty || comment.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/comments'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'postId': widget.custodian['id'],
          'username': utf8.encode(name),    // ✅ Encode UTF-8 เฉพาะค่าข้อความ
          'comment': utf8.encode(comment),  // ✅ Encode UTF-8 เฉพาะค่าข้อความ
        }),
      );

      if (response.statusCode == 201) {
        _nameController.clear();
        _commentController.clear();
        fetchComments();
      }
    } catch (error) {
      print('Error adding comment: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
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
            Text("Age: ${widget.custodian['age']}"),
            Text("Gender: ${widget.custodian['gender']}"),
            Text("Price: ${widget.custodian['price']}"),
            SizedBox(height: 20),

            // 🔹 แสดงความคิดเห็น
            Expanded(
              child: _comments.isEmpty
                  ? Center(child: Text("ยังไม่มีความคิดเห็น"))
                  : ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(Icons.account_circle, color: Colors.orange),
                      title: Text(_comments[index]['username'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_comments[index]['comment']),
                    ),
                  );
                },
              ),
            ),

            // 🔹 ช่องกรอกชื่อ + ช่องกรอกความคิดเห็น (ให้อยู่บรรทัดเดียวกัน)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "ชื่อของคุณ...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                    ),
                  ),
                ),
                SizedBox(width: 8), // ระยะห่างระหว่างช่องกรอกชื่อกับความคิดเห็น
                Expanded(
                  flex: 4,
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
                SizedBox(width: 8), // ระยะห่างระหว่างช่องกรอกกับปุ่มส่ง
                IconButton(
                  icon: Icon(Icons.send, color: Colors.orange),
                  onPressed: () {
                    addComment(_nameController.text, _commentController.text);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
