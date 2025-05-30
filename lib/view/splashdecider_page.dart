import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SplashDeciderPage extends StatefulWidget {
  const SplashDeciderPage({super.key});

  @override
  State<SplashDeciderPage> createState() => _SplashDeciderPageState();
}

class _SplashDeciderPageState extends State<SplashDeciderPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;

  Color _backgroundColor = Colors.orange;
  bool _startBackgroundTransition = false;

  @override
  void initState() {
    super.initState();

    // Animasi logo scale dari 0 ke 1 dalam 1 detik
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _logoScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoController.forward();

    // Setelah 2 detik, mulai transisi background ke putih selama 1.5 detik
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _startBackgroundTransition = true;
      });

      // Ganti warna background dari orange ke putih pakai AnimatedContainer selama 1.5 detik
      Future.delayed(const Duration(milliseconds: 1500), () {
        // Setelah animasi background selesai, lanjut navigasi
        decideNavigation();
      });
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  Future<void> decideNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');

    if (userId == null || token == null) {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    try {
      final url = Uri.parse('http://10.0.2.2:3000/view-room/$userId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("response view room:   ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hasRoom = data is List && data.isNotEmpty;

        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          hasRoom ? '/home' : '/homeNull',
        );
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/homeNull');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan AnimatedContainer untuk transisi warna background
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1500),
        color: _startBackgroundTransition ? Colors.white : Colors.orange,
        child: Center(
          child: ScaleTransition(
            scale: _logoScaleAnimation,
            child: Image.asset(
              'assets/logo.png',
              width: 250,
            ),
          ),
        ),
      ),
    );
  }
}
