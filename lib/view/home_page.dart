import 'package:flutter/material.dart';
import 'package:flutter_se/view/create_room_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8C42);
    const lightOrange = Color(0xFFFFC692);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Welcome New NomNomers!",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.orange),
            iconSize: 45,
            onPressed: () {
              setState(() {
                currentIndex = 3; // Langsung ke HistoryPage
              });
            },
          )
        ],
      ),
      body: const SharedPage(), // Semua halaman menggunakan SharedPage
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: orange,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: lightOrange,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          ],
        ),
      ),
    );
  }
}

class SharedPage extends StatelessWidget {
  const SharedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          color: Colors.grey,
          thickness: 0.5,
          height: 0,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "To continue your experience with NomNomSave, please create or join a room to be able to add product",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateRoomPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Create a Room"),
                    ),
                    const SizedBox(width: 16),
                    const Text("or", style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigasi ke halaman Join Room
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Join a Room"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}