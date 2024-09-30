import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HomePage.dart';

class UpdateProfile extends StatefulWidget {
  final Size screenSize;

  UpdateProfile({Key? key, required this.screenSize}) : super(key: key);

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _updateUserInfo(BuildContext context) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        String name = _nameController.text;
        String password = _passwordController.text;
        String confirmPassword = _confirmPasswordController.text;

        if (password == confirmPassword) {
          // Update Firestore
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'name': name,
          });
          // Update Firebase Authentication password
          await user.updatePassword(password);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("User info updated successfully"),
          ));

          // Clear the input fields
          _nameController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Passwords do not match"),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("You are not logged in"),
        ));
      }
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error updating info $error"),
      ));
    }
  }

  int userReportCount = 0; // To store the report count

  @override
  void initState() {
    super.initState();
    _fetchUserReportCount(); // Fetch count when the widget is initialized
  }

  Future<void> _fetchUserReportCount() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userEmail = user.email ?? ''; // Get user's email

        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('reports')
            .where('userEmail', isEqualTo: userEmail)
            .get();

        setState(() {
          userReportCount = querySnapshot.size;
        });
      }
    } catch (e) {
      print("Error fetching report count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: widget.screenSize.height * 0.09,
                  left: widget.screenSize.width * 0.09
                ),
                child: SizedBox(
                  width: widget.screenSize.width * 0.4,
                  child: Text(
                    "BinGo",
                    style: TextStyle(
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.bold,
                      fontSize: widget.screenSize.width * 0.1,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: widget.screenSize.height * 0.01,
                  left: widget.screenSize.width * 0.25,
                ),
                child: SizedBox(
                  width: widget.screenSize.width * 0.8,
                  child: Text(
                    "Update Profile",
                    style: TextStyle(
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.bold,
                      fontSize: widget.screenSize.width * 0.07,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: widget.screenSize.height * 0.01,
              ),
              Container(
                width: widget.screenSize.width * 0.9,
                height: widget.screenSize.height * 0.59,
                decoration: BoxDecoration(
                  color: const Color(0xffE0FFFF),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 152, 152, 152),
                      spreadRadius: 3,
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: widget.screenSize.height * 0.015),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.screenSize.width * 0.05,
                      ),
                      child: Text(
                        "Name:",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: widget.screenSize.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: widget.screenSize.height * 0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.screenSize.width * 0.05,
                      ),
                      child: SizedBox(
                        height: widget.screenSize.height * 0.068,
                        width: widget.screenSize.width * 0.85,
                        child: TextField(
                          controller: _nameController,
                          obscureText: false,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF0F0F0),
                            border: InputBorder.none,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(
                                  widget.screenSize.width * 0.02),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(
                                  widget.screenSize.width * 0.1),
                            ),
                            hintText: 'Enter your name',
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: widget.screenSize.height * 0.01),
                    SizedBox(height: widget.screenSize.height * 0.015),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.screenSize.width * 0.05,
                      ),
                      child: Text(
                        "Password:",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: widget.screenSize.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: widget.screenSize.height * 0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.screenSize.width * 0.05,
                      ),
                      child: SizedBox(
                        height: widget.screenSize.height * 0.068,
                        width: widget.screenSize.width * 0.85,
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF0F0F0),
                            border: InputBorder.none,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(
                                  widget.screenSize.width * 0.02),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(
                                  widget.screenSize.width * 0.1),
                            ),
                            hintText: 'Enter your Password',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: widget.screenSize.height * 0.025),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.screenSize.width * 0.05,
                      ),
                      child: Text(
                        "Confirm Password:",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: widget.screenSize.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: widget.screenSize.height * 0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.screenSize.width * 0.05,
                      ),
                      child: SizedBox(
                        height: widget.screenSize.height * 0.068,
                        width: widget.screenSize.width * 0.85,
                        child: TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF0F0F0),
                            border: InputBorder.none,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(
                                  widget.screenSize.width * 0.02),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(
                                  widget.screenSize.width * 0.1),
                            ),
                            hintText: 'Enter Password Again',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: widget.screenSize.height * 0.05),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.screenSize.width * 0.3,
                      ),
                      child: SizedBox(
                        width: widget.screenSize.width * 0.3,
                        height: widget.screenSize.height * 0.06,
                        child: TextButton(
                          onPressed: () {
                            _updateUserInfo(context);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(255, 255, 153, 1),
                            ),
                            foregroundColor: MaterialStateProperty.all(
                              Colors.white,
                            ),
                            padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(
                                vertical: widget.screenSize.height * 0.015,
                              ),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  widget.screenSize.width * 0.02,
                                ),
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Update",
                              style: TextStyle(
                                fontSize: widget.screenSize.width * 0.042,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Removed SizedBox here
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
