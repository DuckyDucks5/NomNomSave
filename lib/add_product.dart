import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add Product',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: AddProductScreen(),
    );
  }
}

class AddProductScreen extends StatefulWidget {
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _productNameController = TextEditingController();
  DateTime? _selectedDate;

  String? _selectedGroup;
  String? _selectedCategory;

  final List<String> _groupOptions = ['Group A', 'Group B'];
  final List<String> _categoryOptions = ['Category 1', 'Category 2'];

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
      backgroundColor: Color(0xFFFFD6A5), // peach background
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Add Product',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ListView(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Please enter information of the product you want to save",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Group Selected'),
                      value: _selectedGroup,
                      items: _groupOptions
                          .map<DropdownMenuItem<String>>((group) => DropdownMenuItem<String>(
                                child: Text(group),
                                value: group,
                              ))
                          .toList(),
                      onChanged: (String? val) => setState(() => _selectedGroup = val),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _productNameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'Enter your product name',
                      ),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration:
                          InputDecoration(labelText: 'Product Category'),
                      value: _selectedCategory,
                      items: _categoryOptions
                          .map<DropdownMenuItem<String>>((cat) => DropdownMenuItem<String>(
                                child: Text(cat),
                                value: cat,
                              ))
                          .toList(),
                      onChanged: (String? val) =>
                          setState(() => _selectedCategory = val),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Expired Date',
                          filled: true,
                          fillColor: Color(0xFFFFE0B2),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'dd / mm / yyyy'
                              : '${_selectedDate!.day.toString().padLeft(2, '0')} / '
                                  '${_selectedDate!.month.toString().padLeft(2, '0')} / '
                                  '${_selectedDate!.year}',
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFA726),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Add product logic here
                        },
                        child: Text(
                          'Add Product',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
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
