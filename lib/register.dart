import 'package:flutter/material.dart';
import 'login_screen.dart';  // นำเข้าหน้า login
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _password;
  String? _gender;
  String? _phoneNumber;
  bool _subscribe = false;
  bool _isPasswordVisible = false; // ตัวแปรสำหรับแสดง/ซ่อนรหัสผ่าน

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Prepare data for the API
      final Map<String, dynamic> userData = {
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
        'password': _password,
        'phoneNumber': _phoneNumber,
        'gender': _gender,
        'subscribe': _subscribe ? 1 : 0, // ส่งค่าการสมัครรับข่าวสารด้วย
      };

      try {
        // Call the API to save data to the database
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/register'), // Replace with your actual API endpoint
          headers: {'Content-Type': 'application/json'},
          body: json.encode(userData),
        );

        if (response.statusCode == 201) {  // HTTP status code 201 is created
          // Successfully signed up, navigate to login page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to login page
          );
        } else {
          // Show error message if signup fails
          final data = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Signup failed')),
          );
        }
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')), // Handle network error
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),
              Center(
                child: Image.asset('assets/logo.png', height: 150),
              ),
              const SizedBox(height: 10),

              Center(
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildTextField(
                      labelText: 'First Name',
                      onSaved: (value) => _firstName = value,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildTextField(
                      labelText: 'Last Name',
                      onSaved: (value) => _lastName = value,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              _buildTextField(
                labelText: 'Email address',
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => _email = value,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 5),

              // ช่องกรอกรหัสผ่านพร้อมตัวเลือกให้แสดงหรือซ่อนรหัสผ่าน
              _buildPasswordField(),

              const SizedBox(height: 5),

              Row(
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: _buildTextField(
                      labelText: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      onSaved: (value) => _phoneNumber = value,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    flex: 3,
                    child: _buildDropdown(
                      labelText: 'Gender',
                      value: _gender,
                      onChanged: (String? newValue) {
                        setState(() {
                          _gender = newValue!;
                        });
                      },
                      items: ['Male', 'Female', 'Other'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              Row(
                children: [
                  Checkbox(
                    value: _subscribe,
                    onChanged: (bool? value) {
                      setState(() {
                        _subscribe = value!;
                      });
                    },
                  ),
                  const Text('Sign Up for emails to get updates from Dogs \n and Cats.'),
                ],
              ),
              const SizedBox(height: 5),

              ElevatedButton(
                onPressed: _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Create account', style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 5),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text('Login', style: TextStyle(color: Colors.orange)),
                  ),
                ],
              ),

              Center(
                child: Image.asset('assets/1.png', height: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  // สร้างช่องกรอกรหัสผ่านพร้อมปุ่มให้ดู/ซ่อน
  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Password',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        obscureText: !_isPasswordVisible, // ควบคุมการแสดงรหัสผ่าน
        validator: (value) {
          if (value == null || value.isEmpty || value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _buildDropdown({
    required String labelText,
    required String? value,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        value: value,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

