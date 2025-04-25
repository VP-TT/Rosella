// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAuthScreen extends StatefulWidget {
  const UserAuthScreen({Key? key}) : super(key: key);

  @override
  State<UserAuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<UserAuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        if (_isLogin) {
          // Login
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

          // For login, we'll use the stored username if available
          final prefs = await SharedPreferences.getInstance();
          final username = prefs.getString('username') ?? 'User';

          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            '/personalized_welcome',
            arguments: username,
          );
        } else {
          // Sign up
          final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

          // Store username in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', _usernameController.text.trim());

          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            '/personalized_welcome',
            arguments: _usernameController.text.trim(),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'user-disabled':
            errorMessage = 'This user has been disabled.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found for this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          case 'email-already-in-use':
            errorMessage = 'An account already exists for this email.';
            break;
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email/password accounts are not enabled.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many attempts. Try again later.';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your connection.';
            break;
          default:
            errorMessage = 'An error occurred: ${e.message}';
        }
        setState(() {
          _error = errorMessage;
        });
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCECF1),
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
        backgroundColor: const Color(0xFFE75A7C),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with illustration
                Center(
                  child: Image.asset(
                    'assets/images/welcome_illustration.png',
                    height: 150,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  _isLogin ? 'Welcome Back!' : 'Create Your Account',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE75A7C),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isLogin
                      ? 'Log in to continue your period tracking journey'
                      : 'Sign up to start your period tracking journey',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // Error message
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Username field (only for signup)
                if (!_isLogin)
                  Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'How should we call you?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          prefixIcon: const Icon(Icons.person, color: Color(0xFFE75A7C)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Color(0xFFE75A7C), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (!_isLogin && (value == null || value.isEmpty)) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: const Icon(Icons.email, color: Color(0xFFE75A7C)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFFE75A7C), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: _isLogin ? 'Enter your password' : 'Create a secure password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFFE75A7C)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFFE75A7C), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (!_isLogin && value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Submit button
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE75A7C)),
                  )
                      : ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE75A7C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _isLogin ? 'Login' : 'Sign Up',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Toggle between login and signup
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'Don\'t have an account? Sign Up'
                          : 'Already have an account? Login',
                      style: const TextStyle(
                        color: Color(0xFFE75A7C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
