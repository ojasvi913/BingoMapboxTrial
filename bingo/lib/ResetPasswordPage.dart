import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  String _email = '';
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Check if email exists in Firestore
        bool emailExists = await checkIfEmailExists(_email);
        if (!emailExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user found for that email.')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Send password reset email
        await _auth.sendPasswordResetEmail(email: _email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent')),
        );
      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred. Please try again later.';
        if (e.code == 'user-not-found') {
          message = 'No user found for that email.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again later.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> checkIfEmailExists(String email) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users') // Replace 'users' with your collection name
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    final List<DocumentSnapshot> documents = result.docs;
    return documents.length == 1;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFFFF3E0), // Light orange background
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: screenSize.height * 0.2, left: screenSize.width * 0.1),
          child: Container(
            width: screenSize.width * 0.8,
            height: screenSize.height * 0.5,
            decoration: BoxDecoration(
              color: Colors.white, // or use Color(0xFFFFFAF0) for a very light orange
              borderRadius: BorderRadius.circular(screenSize.width * 0.02),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3), // Orange shadow
                  spreadRadius: screenSize.width * 0.005,
                  blurRadius: screenSize.width * 0.02,
                  offset: Offset(0, screenSize.width * 0.01),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: screenSize.height * 0.04),
                      SizedBox(
                        height: screenSize.width * 0.3,
                        width: screenSize.height * 0.18,
                        child: Image.asset(
                          'Images/ForgotPassword2.png',
                          height: screenSize.height * 0.25,
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.03),
                      Padding(
                        padding: EdgeInsets.only(top: screenSize.height * 0, left: screenSize.width * 0),
                        child: SizedBox(
                          width: screenSize.width * 0.7,
                          child: Text(
                            "Forgot Password",
                            style: TextStyle(
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold,
                              fontSize: screenSize.width * 0.07,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: screenSize.height * 0.0, left: screenSize.width * 0),
                        child: SizedBox(
                          width: screenSize.width * 0.7,
                          child: Text(
                            "Enter your email and we'll send a link to reset your password",
                            style: TextStyle(
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.normal,
                              fontSize: screenSize.width * 0.03,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: screenSize.height * 0.09,
                        width: screenSize.width * 0.7,
                        child: TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF0F0F0),
                            border: InputBorder.none,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(screenSize.width * 0.1),
                            ),
                            hintText: 'Enter your email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _email = value!;
                          },
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  _submitForm();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.orange, // White text color
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Reset Password'),
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