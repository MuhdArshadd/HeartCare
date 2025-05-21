 import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heartcare/view/login_screen.dart';
import 'package:heartcare/view/resetpassword_screen.dart';

import '../controller/resetpassword_controller.dart';
import '../controller/user_controller.dart';


class VerificationCodeScreen extends StatefulWidget {
  final String email;
  final String newPass;

  const VerificationCodeScreen({super.key, required this.email, required this.newPass});

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  int? _sentCode; // To store the generated verification code
  bool _isCodeSent = false;

  // Controllers for each digit input
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();
  final TextEditingController _controller5 = TextEditingController();
  final TextEditingController _controller6 = TextEditingController();

  // FocusNodes to control focus for each text field
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();
  final FocusNode _focusNode5 = FocusNode();
  final FocusNode _focusNode6 = FocusNode();

  // Method to send verification code via email
  Future<void> _sendVerificationCode() async {
    final ResetPassword _resetPassword = ResetPassword(); // Instance of ResetPassword controller
    setState(() {
      _isCodeSent = true;
    });

    _sentCode = await _resetPassword.sendEmail(widget.email); // Use widget.email to access passed email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification code sent to your email!')),
    );
  }


  // Method to validate the entered verification code
  Future<void> _verifyCode() async {
    String success = "";
    String enteredCode =
        _controller1.text + _controller2.text + _controller3.text +
            _controller4.text + _controller5.text + _controller6.text;

    if (enteredCode == _sentCode.toString()) {
      //update the password
      final UserController userController = UserController();
      success = await userController.resetPass("password_verification_page",widget.email, widget.newPass);

      if (success == "Password update successful.") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification successful!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false, // removes all previous routes
        );
      } else if (success == "Failed to update password.") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update password.')),
        );
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect verification code. Please try again.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _sendVerificationCode(); // Automatically send the code when page is loaded based on entered email from resetPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            height: 200.0,
            child: Image.asset('assets/images/HeartCare_logo.png'),
          ),
          const Positioned(
            top: 350.0,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Verification Code',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          Positioned(
            top: 400.0,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Enter the verification code we sent to your email...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
            ),
          ),
          Positioned(
            top: 500.0,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 6; i++) ...[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: buildVerificationDigitField(
                                [ _controller1, _controller2, _controller3, _controller4, _controller5, _controller6 ][i],
                                [ _focusNode1, _focusNode2, _focusNode3, _focusNode4, _focusNode5, _focusNode6 ][i],
                                i == 5 ? _focusNode6 : [ _focusNode1, _focusNode2, _focusNode3, _focusNode4, _focusNode5, _focusNode6 ][i + 1],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 50.0),
                  ElevatedButton(
                    onPressed: _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Confirm', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ResetScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: const Text('Back', style: TextStyle(fontSize: 18, color: Colors.black54)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVerificationDigitField(TextEditingController controller, FocusNode currentFocus, FocusNode nextFocus) {
    return SizedBox(
      width: 50.0,
      child: TextField(
        controller: controller,
        focusNode: currentFocus,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        onChanged: (value) {
          if (value.isNotEmpty) FocusScope.of(context).requestFocus(nextFocus);
        },
        decoration: const InputDecoration(
          counterText: "",
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        ),
      ),
    );
  }
}
