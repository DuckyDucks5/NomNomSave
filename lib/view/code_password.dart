import 'package:flutter/material.dart';
import 'package:flutter_se/view/reset_password_page.dart';

import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CodePasswordPage extends StatefulWidget {
  final String email;
  const CodePasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  State<CodePasswordPage> createState() => _CodePasswordPageState();
}

class _CodePasswordPageState extends State<CodePasswordPage> {
  TextEditingController otpController = TextEditingController();

  Future<void> _reSendVerificationCode(String email) async {
    final url = Uri.parse('https://nomnomsave-be-se-production.up.railway.app/resend-verify-code');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Sukses kirim kode
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code sent to your email')),
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

  Future<void> _VerifyCode(String email, String code) async {
    final url = Uri.parse('https://nomnomsave-be-se-production.up.railway.app/verify-code');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      if (response.statusCode == 200) {
        // Sukses kirim kode
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code verified successfully'),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(email: email),
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
                'code sent to your registered email',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // OTP input
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: otpController,
                animationType: AnimationType.fade,
                keyboardType: TextInputType.number,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(6),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeColor: Colors.grey.shade300,
                  selectedColor: orange,
                  inactiveColor: Colors.grey.shade300,
                ),
                onChanged: (value) {},
              ),

              // Sent again
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _reSendVerificationCode(widget.email);
                  },
                  child: Text('sent again', style: TextStyle(color: orange)),
                ),
              ),

              const Spacer(),

              // Submit button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _VerifyCode(widget.email, otpController.text);
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
