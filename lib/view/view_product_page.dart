import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_se/view/update_product_page.dart';
import 'package:flutter_se/view/product_page.dart';

class ViewProductCategory extends StatefulWidget {
  final String category;
  final int teamId;
  final int categoryId;

  const ViewProductCategory({
    super.key,
    required this.category,
    required this.teamId,
    required this.categoryId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ViewProductCategoryState createState() => _ViewProductCategoryState();
}

class _ViewProductCategoryState extends State<ViewProductCategory> {
  List<dynamic> productList = [];
  String _sortOption = 'Expiration (Soonest)';
  final List<String> sortOptions = [
    'Expiration (Soonest)',
    'Expiration (Latest)',
    'Name (A-Z)',
  ];

  @override
  void initState() {
    super.initState();
    fetchProductList();
  }

  Future<void> fetchProductList() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');

    if (userId == null) {
      return;
    }

    final url = Uri.parse(
      'http://10.0.2.2:3000/view-product-category/$userId/${widget.categoryId}/${widget.teamId}',
    );
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
        productList = data;
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> _deleteProduct(int productId) async {
final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final url = Uri.parse('http://10.0.2.2:3000/delete-product/$productId');
      final response = await http.delete(
        url,
        headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      );
      if (response.statusCode == 200) {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder:
                (context) => ViewProductCategory(
                  category: widget.category,
                  teamId: widget.teamId,
                  categoryId: widget.categoryId,
                ),
          ),
        );
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete room');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text('Error deleting room')));
    }
  }

  Future<void> _markAsConsumed(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    try {
      final url = Uri.parse('http://10.0.2.2:3000/mark-consumed/$productId');
      final response = await http.put(
        url,
        headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      );
      if (response.statusCode == 200) {
        fetchProductList(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product marked as consumed')),
        );
      } else {
        throw Exception('Failed to mark product as consumed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error marking as consumed')),
      );
    }
  }

  void _showInfo(BuildContext context, dynamic product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 380,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Text(
                product['ProductName'],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors
                          .orange, // gunakan 'orange' jika sudah dideklarasikan
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pop(context); // tutup modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => UpdateProductPage(
                            productId: product['ProductID'],
                            teamId: widget.teamId,
                            categoryId: widget.categoryId,
                            categoryName: widget.category,
                          ),
                    ),
                  );
                },
                child: const Text(
                  "Update Product",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pop(context); // tutup modal
                  _markAsConsumed(product['ProductID']);
                },
                child: const Text(
                  "Mark as Consumed",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pop(context); // tutup modal
                  _showDeleteConfirmation(context, product['ProductID']);
                },
                child: const Text(
                  "Delete Product",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.orange,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.orange,
                      decorationThickness: 2.0,
                      height: 2.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int productId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (BuildContext sheetContext) => Container(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Are you sure to delete this product?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                    children: [
                      const TextSpan(
                        text:
                            "By deleting this product, the product and its information will be deleted ",
                      ),
                      TextSpan(
                        text: "permanently,",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: " Proceed?"),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _deleteProduct(productId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Delete Product",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.orange,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.orange,
                      decorationThickness: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Search bar and sort
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search Your Product',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sort by:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: _sortOption,
                      onChanged: (value) {
                        setState(() {
                          _sortOption = value!;
                          _sortProducts();
                        });
                      },
                      items:
                          sortOptions.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Product list
            Expanded(
              child:
                  productList.isEmpty
                      ? const Center(child: Text('No products found.'))
                      : ListView.builder(
                        itemCount: productList.length,
                        itemBuilder: (context, index) {
                          final product = productList[index];
                          final daysLeft = product['daysLeft'];
                          final addedBy = product['UserName'] ?? 'Unknown';
                          final formattedDate = product['FormattedExpiredDate'];

                          Color statusColor;
                          String statusLabel;

                          if (daysLeft >= 0 && daysLeft <= 5) {
                            statusColor = Colors.red;
                            statusLabel = '● Expired Soon';
                          } else if (daysLeft >= 6 && daysLeft <= 14) {
                            statusColor = Colors.orange;
                            statusLabel = '● Almost Expired';
                          } else {
                            statusColor = Colors.green;
                            statusLabel = '● Fresh';
                          }

                          String dayText =
                              (daysLeft == 0) ? 'Today' : '$daysLeft Days Left';

                          return GestureDetector(
                            onTap: () => _showInfo(context, product),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: statusColor,
                                    width: 5,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          dayText,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          statusLabel,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product['ProductName'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'added by $addedBy',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _sortProducts() {
    if (_sortOption == 'Expiration (Soonest)') {
      productList.sort((a, b) => a['daysLeft'].compareTo(b['daysLeft']));
    } else if (_sortOption == 'Expiration (Latest)') {
      productList.sort((a, b) => b['daysLeft'].compareTo(a['daysLeft']));
    } else if (_sortOption == 'Name (A-Z)') {
      productList.sort(
        (a, b) => a['ProductName'].toLowerCase().compareTo(
          b['ProductName'].toLowerCase(),
        ),
      );
    }
  }
}
