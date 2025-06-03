import 'package:flutter/material.dart';
import 'package:flutter_se/view/code_password.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EnterEmailPage extends StatefulWidget {
  const EnterEmailPage({Key? key}) : super(key: key);

  @override
  State<EnterEmailPage> createState() => _EnterEmailPageState();
}

class _EnterEmailPageState extends State<EnterEmailPage> {
  TextEditingController emailController = TextEditingController();

  Future<void> _sendVerificationCode(String email) async {
    final url = Uri.parse('https://nomnomsave-be-se-production.up.railway.app/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        // Sukses kirim kode
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code sent to your email')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CodePasswordPage(email: email),
          ),
        );
      } else {
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody['message'] ?? 'Something went wrong'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color orange = Colors.orange;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'RESET PASSWORD',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Enter your email to receive a verification code',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 16),

              // Email input field
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  // labelText: 'Email',
                  hintText: 'Enter your email address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const Spacer(),

              // Submit button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your email'),
                        ),
                      );
                      return;
                    }
                    _sendVerificationCode(emailController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(), // <- oval shape
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 18,
                    ),
                    backgroundColor: orange,
                    shadowColor: Colors.grey,
                    elevation: 5,
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
