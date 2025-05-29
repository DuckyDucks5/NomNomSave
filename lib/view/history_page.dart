import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> productList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // refreshHistory();
    fetchHistoryProduct();// Panggil refresh saat halaman pertama kali muncul
  }

  Future<void> refreshHistory() async {
    setState(() {
      isLoading = true;
    });

    await fetchHistoryProduct(); 
  }

  Future<void> fetchHistoryProduct() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');

    if (userId == null) {
      return;
    }

    final url = Uri.parse('http://10.0.2.2:3000/history-product/$userId');
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
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      debugPrint('Failed to fetch history product');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : productList.isEmpty
                    ? const Center(child: Text('No products found.'))
                    : RefreshIndicator(
                        onRefresh: refreshHistory,
                        child: ListView.builder(
                          itemCount: productList.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 16),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Product History',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            final product = productList[index - 1];
                            final productStatus = product['ProductStatus'];
                            final formattedDate = product['ExpiredDate'];
                            final roomName = product['TeamName'] ?? 'Unknown Room';

                            Color statusColor;
                            String statusLabel;

                            if (productStatus == 2) {
                              statusColor = Colors.red;
                              statusLabel = 'Expired';
                            } else if (productStatus == 3) {
                              statusColor = Colors.green;
                              statusLabel = 'Consumed';
                            } else {
                              statusColor = Colors.grey;
                              statusLabel = 'Unknown';
                            }

                            return Container(
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
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
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
                                          statusLabel,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          roomName,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          product['ProductName'],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
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
                            );
                          },
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
