import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'home.dart';

void main() {
  runApp(ListPage());
}

class ListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DepositListPage(),
    );
  }
}

class DepositListPage extends StatefulWidget {
  @override
  _DepositListPageState createState() => _DepositListPageState();
}

class _DepositListPageState extends State<DepositListPage> {
  int _currentIndex = 0;
  late Future<List<PetOwner>> _petOwners;

  @override
  void initState() {
    super.initState();
    _petOwners = fetchPetOwners();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {

      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        break;
    }
  }

  Future<void> deletePetOwner(int id) async {
    try {
      final response = await http.delete(Uri.parse('http://10.0.2.2:3000/pet-owners/$id'));
      if (response.statusCode == 200) {
        setState(() {
          _petOwners = fetchPetOwners();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pet Owner Deleted')));
      } else {
        throw Exception('Failed to delete pet owner');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deposit List'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<PetOwner>>(
        future: _petOwners,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pet owners found.'));
          } else {
            final petOwners = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: petOwners.length,
              itemBuilder: (context, index) {
                return DepositCard(
                  petOwner: petOwners[index],
                  onDelete: () => deletePetOwner(petOwners[index].id),
                );
              },
            );
          }
        },
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
}

class PetOwner {
  final int id;
  final String name;
  final String petName;
  final String ageGroup;
  final String gender;
  final String category;
  final String phone;
  final String pickUpDate;

  PetOwner({
    required this.id,
    required this.name,
    required this.petName,
    required this.ageGroup,
    required this.gender,
    required this.category,
    required this.phone,
    required this.pickUpDate,
  });

  factory PetOwner.fromJson(Map<String, dynamic> json) {
    return PetOwner(
      id: json['id'] ?? 0,  // Default to 0 if null
      name: json['name'] ?? 'N/A',
      petName: json['pet_name'] ?? 'N/A',
      ageGroup: json['age_group'] ?? 'N/A',
      gender: json['gender'] ?? 'N/A',
      category: json['category'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      pickUpDate: json['pick_up_date'] ?? '0000-00-00',
    );
  }
}


Future<List<PetOwner>> fetchPetOwners() async {
  try {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/pet-owners'));
    print('API Response: ${response.body}');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => PetOwner.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load pet owners');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Error: $e');
  }
}

class DepositCard extends StatelessWidget {
  final PetOwner petOwner;
  final VoidCallback onDelete;

  const DepositCard({
    required this.petOwner,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    DateTime parsedDate = DateTime.parse(petOwner.pickUpDate);
    String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

    return Card(
      color: Colors.purple.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.pets, size: 60, color: Colors.grey.shade700),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gender: ${petOwner.gender}'),
                  Text('Age: ${petOwner.ageGroup}'),
                  Text('Phone: ${petOwner.phone}'),
                  Text('Pick up date: $formattedDate'),
                  Text('Disease: ${petOwner.category}'),

                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
