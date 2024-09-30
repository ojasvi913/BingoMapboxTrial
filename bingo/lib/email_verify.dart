import 'package:bingo/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResendEmailVerifyPage extends StatefulWidget {
  const ResendEmailVerifyPage({Key? key}) : super(key: key);

  @override
  _ResendEmailVerifyPageState createState() => _ResendEmailVerifyPageState();
}

class _ResendEmailVerifyPageState extends State<ResendEmailVerifyPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isProcessing = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkUserStatus() async {
    User? user = _auth.currentUser;

    if (user == null) {
      setState(() {
        _message = 'No user is signed in. Please sign in.';
      });
    } else if (user.emailVerified) {
      setState(() {
        _message = 'Your email is already verified.';
      });
    } else {
      setState(() {
        _message = 'Your email is not verified. Please request a new verification email.';
      });
    }
  }

  Future<void> _handleLoginAndResendEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _message = ''; // Clear previous message
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          setState(() {
            _message = 'Verification email sent. Please check your inbox.';
          });
        } else {
          setState(() {
            _message = 'Your email is already verified.';
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = e.message ?? 'Failed to sign in or send verification email.';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _navigateToLoginPage() {
    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(screenSize.width * 0.05),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Resend Verification",
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.07,
                    color: const Color(0xFF00796B),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.03),
                Container(
                  padding: EdgeInsets.all(screenSize.width * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenSize.width * 0.03),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        spreadRadius: screenSize.width * 0.005,
                        blurRadius: screenSize.width * 0.03,
                        offset: Offset(0, screenSize.width * 0.01),
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "We need you to sign in to verify your email.",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: screenSize.width * 0.045,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenSize.height * 0.03),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email, color: Colors.grey),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: Colors.grey),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.03),
                      ElevatedButton(
                        onPressed: _isProcessing ? null : _handleLoginAndResendEmail,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(const Color(0xFF00796B)),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(vertical: screenSize.height * 0.015),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenSize.width * 0.03),
                            ),
                          ),
                        ),
                        child: Center(
                          child: _isProcessing
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  "Resend Email",
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.04,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      if (_message.isNotEmpty)
                        Text(
                          _message,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: screenSize.width * 0.04,
                            fontWeight: FontWeight.normal,
                            color: _message.contains('Failed') ? Colors.red : Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      SizedBox(height: screenSize.height * 0.03),
                      TextButton(
                        onPressed: _navigateToLoginPage,
                        child: Text(
                          "Go to Login Page",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: screenSize.width * 0.04,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF00796B),
                          ),
                        ),
                      ),
                    ],
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
