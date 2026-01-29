import 'package:flutter/material.dart';
import 'package:heartcare/model/user_model.dart';
import 'package:heartcare/view/resetpassword_screen.dart';
import 'package:heartcare/view/signup_screen.dart';
import 'package:provider/provider.dart';
import '../controller/user_controller.dart';
import '../model/provider/user_provider.dart';
import 'app_bar/main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final UserController userController = UserController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Image.asset(
                      'assets/images/HeartCare_logo.png',
                      height: 150,
                      width: 150,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Hello!',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Log into your account',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    // Username Field
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: 'Enter your username',
                        border: OutlineInputBorder(),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        hintText: 'Enter your password',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const ResetScreen()),
                          );
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String username = _usernameController.text;
                            String password = _passwordController.text;
                            String hashedPassword = userController.hashPassword(password);

                            UserModel? user = await userController.userLogin(username, password, hashedPassword);

                            print('DEBUG: Logged in user ->');
                            print('user ID: ${user?.userID}');
                            print('Username: ${user?.username}');
                            print('Full Name: ${user?.fullname}');
                            print('Email: ${user?.emailAddress}');
                            print('Password: ${user?.password}');
                            print('Age: ${user?.age}');
                            print('Sex: ${user?.sex}');
                            print('Body Weight: ${user?.bodyWeight}');
                            print('Height: ${user?.height}');
                            print('Family History of CVD: ${user?.familyHistoryCvd}');
                            print('Ethnicity Group: ${user?.ethnicityGroup}');
                            print('Marital Status: ${user?.maritalStatus}');
                            print('Employment Status: ${user?.employmentStatus}');
                            print('Education Level: ${user?.educationLevel}');
                            print('Profile Image: ${user?.profileImage != null && user!.profileImage!.isNotEmpty ? 'Available' : 'Null'}');

                            if (user != null) {
                              // Save to global state and shared preferences
                              Provider.of<UserProvider>(context, listen: false).setUser(user);

                              showDialog(
                                context: context,
                                barrierDismissible: false, // Prevent dismissal
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 10,
                                    backgroundColor: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey[100],
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const CircularProgressIndicator(strokeWidth: 3),
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            'Logging In...',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Please wait while we prepare your dashboard.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 14, color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );

                              // Wait 1 second before navigating
                              await Future.delayed(const Duration(seconds: 1));

                              // Dismiss the dialog
                              Navigator.of(context, rootNavigator: true).pop();

                              // Navigate to the next screen
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const MainNavigationScreen(selectedIndex: 0)),
                                    (Route<dynamic> route) => false,
                              );
                            } else {
                              // Show login failed error
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invalid username or password')),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Register Prompt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const SignUpScreen()),
                            );
                          },
                          child: const Text(
                            'Register Now',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
