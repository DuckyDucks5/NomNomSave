import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_page.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  List<dynamic> roomList = [];
  final List<String> _groupOptions = [];
  final List<String> _categoryOptions = [
    'Bakery & Bread',
    'Beverages',
    'Canned & Preserved Food',
    'Dairy & Eggs',
    'Frozen Food',
    'Snack & Sweets',
    'Spice & Condiments',
    'Other',
  ];

  final TextEditingController _productNameController = TextEditingController();
  DateTime? _selectedDate;

  String? _selectedGroup;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');

    if (userId == null) {
      return;
    }

    final url = Uri.parse('http://10.0.2.2:3000/view-room/$userId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        roomList = data;
        _groupOptions.clear();
        _groupOptions.addAll(
          roomList.map((msteam) => msteam['TeamName'].toString()),
        );
      });
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<void> _addProduct() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');

    if (userId == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not found')));
      return;
    }

    if (_selectedGroup == null ||
        _selectedCategory == null ||
        _selectedDate == null ||
        _productNameController.text.isEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );

    if (selectedDate.isBefore(today)) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expired date cannot be before today')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:3000/add-product');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'userId': userId,
        'teamName': _selectedGroup,
        'ProductName': _productNameController.text,
        'ExpiredDate': _selectedDate!.toIso8601String(),
        'ProductCategory': _selectedCategory,
      }),
    );

    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context, 'goToProduct');
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const ProductPage()),
      // );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add product')));
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Add Product',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      "Please enter information of the product you want to save",
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 15),

                    // Group Dropdown
                    const Text(
                      "Group Selected",
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      value: _selectedGroup,
                      items:
                          _groupOptions
                              .map(
                                (group) => DropdownMenuItem(
                                  value: group,
                                  child: Text(group),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGroup = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Product Name
                    const Text("Product Name", style: TextStyle(fontSize: 15)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _productNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your product name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Product Category
                    const Text(
                      "Product Category",
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      value: _selectedCategory,
                      items:
                          _categoryOptions
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Expired Date
                    const Text("Expired Date", style: TextStyle(fontSize: 15)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFFFF3E0),
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 12,
                          ),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'dd / mm / yyyy'
                              : '${_selectedDate!.day.toString().padLeft(2, '0')} / '
                                  '${_selectedDate!.month.toString().padLeft(2, '0')} / '
                                  '${_selectedDate!.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 90),

                    // Add Product Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _addProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA726),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Add Product',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
