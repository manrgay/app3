import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'list.dart';  // Import List screen
import 'cat2.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Cat(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Cat extends StatefulWidget {
  @override
  _BasicInfoFormState createState() => _BasicInfoFormState();
}

class _BasicInfoFormState extends State<Cat> {
  final _formKey = GlobalKey<FormState>();

  String? selectedAge;
  String? selectedGender;
  String? selectedCategory;

  final List<String> ages = ['0-6', '7-12', '13-24', '24+'];
  final List<String> genders = ['Male', 'Female', 'Other'];
  final List<String> categories = ['Dog', 'Cat', 'Dog And Cat'];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // เพิ่มฟิลด์อีเมล

  Future<void> _submitForm() async {
    final name = _nameController.text.trim();
    final petName = _petNameController.text.trim();
    final phone = _phoneController.text.trim();
    final pickupDate = _pickupDateController.text.trim();
    final email = _emailController.text.trim(); // รับค่าอีเมล

    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/submit-form'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'petName': petName,
          'age': selectedAge,
          'gender': selectedGender,
          'category': selectedCategory,
          'phone': phone,
          'pickupDate': pickupDate,
          'email': email,  // ส่งอีเมลไปกับข้อมูลอื่นๆ
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ListPage()),  // Navigate to list.dart screen
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['message']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            title: Text('Collect Basic Information'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle Add button action
                    },
                    child: Text('Deposit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BasicInfoForm()),
                      );
                    },
                    child: Text('Post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter your Name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _petNameController,
                decoration: InputDecoration(
                  labelText: 'Pet name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter your Pet name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController, // เพิ่ม TextFormField สำหรับอีเมล
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter an Email' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                value: selectedAge,
                items: ages
                    .map((age) => DropdownMenuItem(value: age, child: Text(age)))
                    .toList(),
                onChanged: (value) => setState(() => selectedAge = value),
                validator: (value) =>
                value == null ? 'Please select your age' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                value: selectedGender,
                items: genders
                    .map((gender) =>
                    DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) => setState(() => selectedGender = value),
                validator: (value) =>
                value == null ? 'Please select your gender' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: selectedCategory,
                items: categories
                    .map((category) => DropdownMenuItem(
                    value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                validator: (value) =>
                value == null ? 'Please select a category' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a Phone' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _pickupDateController,
                decoration: InputDecoration(
                  labelText: 'Pick up date',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _pickupDateController.text =
                          "${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please confirm your Pick up date' : null,
                readOnly: true,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('Create'),
              ),
              SizedBox(height: 16),
              Center(
                child: Image.asset(
                  'assets/1.png',
                  height: 250,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
