import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'view_product_page.dart';

class UpdateProductPage extends StatefulWidget {
  final int productId;
  final int teamId;
  final int categoryId;
  final String categoryName;

  const UpdateProductPage({
    super.key,
    required this.productId,
    required this.teamId,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<UpdateProductPage> createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
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
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _updateProduct() async {
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

    if (_selectedCategory == null ||
        _selectedDate == null ||
        _productNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final url = Uri.parse(
      'https://nomnomsave-be-se-production.up.railway.app/update-product/${widget.productId}',
    );

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'UserID': userId,
        'ProductName': _productNameController.text,
        'ExpiredDate': _selectedDate!.toIso8601String(),
        'ProductCategory': _selectedCategory,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => ViewProductCategory(
                category: widget.categoryName,
                teamId: widget.teamId,
                categoryId: widget.categoryId,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update product')));
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
                    'Update Product',
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
                      "Enter new information for the product",
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 15),

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

                    // Update Product Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateProduct,
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
                          'Update',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
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
