import 'package:flutter/material.dart';

class DeleteProductScreen extends StatelessWidget {
  void _showDeleteConfirmation(BuildContext context, String productName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Are you sure to delete this product?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              "By deleting this product, the product and its\ninformation will be deleted permanently.\nProceed?",
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully Delete the Product'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: Text("Delete Product", style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String addedBy,
    required String date,
    required String status,
    required Color statusColor,
    required Color badgeColor,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () => _showDeleteConfirmation(context, title),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status == 'Fresh' ? 'Fresh' : 'Exp. Soon',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Text('added by $addedBy', style: TextStyle(fontSize: 12)),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(date, style: TextStyle(fontSize: 12, color: Colors.grey)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFD6A5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                    'Bakery & Bread',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Icon(Icons.sort),
                ],
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Your Product',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
            SizedBox(height: 10),

            
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ListView(
                  children: [
                    _buildProductCard(
                      context: context,
                      title: "Sari Roti Roti Sari Roti",
                      addedBy: "Aulyn",
                      date: "20 May 2025",
                      status: "12 Days Left",
                      statusColor: Colors.green,
                      badgeColor: Colors.greenAccent.shade100,
                    ),
                    _buildProductCard(
                      context: context,
                      title: "Choco Cheese Bread",
                      addedBy: "Jessica",
                      date: "20 May 2025",
                      status: "3 Days Left",
                      statusColor: Colors.orange,
                      badgeColor: Colors.orange.shade100,
                    ),
                    _buildProductCard(
                      context: context,
                      title: "Selai Kacang ABC",
                      addedBy: "Jessica",
                      date: "20 May 2025",
                      status: "3 Days Left",
                      statusColor: Colors.orange,
                      badgeColor: Colors.orange.shade100,
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

void main() {
  runApp(MaterialApp(
    home: DeleteProductScreen(),
  ));
}
