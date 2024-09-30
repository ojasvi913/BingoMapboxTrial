import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'LoginPage.dart';
import 'SignupPage.dart';

class SignupPageOne extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const SignupPageOne({
    required this.name,
    required this.email,
    required this.password,
    Key? key,
  }) : super(key: key);

  @override
  _SignupPageOneState createState() => _SignupPageOneState();
}

class _SignupPageOneState extends State<SignupPageOne> {
  String? _selectedAccountType;
  final List<String> _accountTypes = ['User', 'Driver', 'Worker'];
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _areaCodeController = TextEditingController();

  bool isDriverSelected = false;
  bool isWorkerSelected = false;

  Future<void> _showVerificationDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 5), () {
          Navigator.of(context).pop();
          _createAccount();
        });
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(
                child: Text("Verification email sent. Check and verify to login."),
              ),
            ],
          ),
        );
      },
    );
  }

 Future<void> _createAccount() async {
  if (_selectedAccountType == null) {
    _showErrorDialog("Please select an account type");
    return;
  }

  if (isDriverSelected && (_registrationNumberController.text.isEmpty || _zipCodeController.text.isEmpty)) {
    _showErrorDialog("Please fill in all driver fields");
    return;
  }

  if (isWorkerSelected && (_employeeIdController.text.isEmpty || _areaCodeController.text.isEmpty)) {
    _showErrorDialog("Please fill in all worker fields");
    return;
  }

  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: widget.email,
      password: widget.password,
    );

    // Send email verification
    await userCredential.user?.sendEmailVerification();

    Map<String, dynamic> userData = {
      'name': widget.name,
      'email': widget.email,
      'accountType': _selectedAccountType,
    };

    if (isDriverSelected) {
      userData['registrationNumber'] = _registrationNumberController.text;
      userData['zipCode'] = _zipCodeController.text;
    }

    if (isWorkerSelected) {
      userData['employeeId'] = _employeeIdController.text;
      userData['areaCode'] = _areaCodeController.text;
    }

    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(userData);

    // Sign out the user immediately
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).pop(); // Close the dialog

    _showInfoDialog('Account created. Please check your email to verify and then log in from the Login page.');
  } catch (e) {
    print('Error creating account: $e');
    _showErrorDialog('Error creating account: $e');
  }
}

void _showInfoDialog(String message) {
  if (!mounted) return;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Information"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      );
    },
  );
}


  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE0FFFF),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenSize.height,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Image.asset(
                  'Images/Bg.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: screenSize.height * 0.11,
                left: screenSize.width * 0.6,
                child: Text(
                  "1/2",
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w100,
                    fontSize: screenSize.width * 0.05,
                  ),
                ),
              ),
              Positioned(
                top: screenSize.height * 0.1,
                left: screenSize.width * 0.1,
                child: Text(
                  "Just a few \nmore steps",
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.08,
                  ),
                ),
              ),
              Positioned(
                top: screenSize.height * 0.22,
                left: screenSize.width * 0.08,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupPage()),
                    );
                  },
                  child: const Image(
                    image: AssetImage('Images/BackButton.png'),
                  ),
                ),
              ),
              Positioned(
                top: screenSize.height * 0.33,
                left: screenSize.width * 0.05,
                right: screenSize.width * 0.05,
                child: Container(
                  width: screenSize.width * 0.9,
                  padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: screenSize.width * 0.005,
                        blurRadius: screenSize.width * 0.02,
                        offset: Offset(0, screenSize.width * 0.01),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: screenSize.height * 0.015),
                      Text(
                        "Type of account:",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: screenSize.width * 0.04,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.01),
                      Container(
                        height: screenSize.height * 0.068,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedAccountType,
                            hint: const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text('Select an item'),
                            ),
                            isExpanded: true,
                            items: _accountTypes.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(item),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedAccountType = newValue;
                                isDriverSelected = newValue == 'Driver';
                                isWorkerSelected = newValue == 'Worker';
                              });
                            },
                          ),
                        ),
                      ),
                      if (isDriverSelected) ...[
                        SizedBox(height: screenSize.height * 0.015),
                        Text(
                          "Registration Number:",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: screenSize.width * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        Container(
                          height: screenSize.height * 0.068,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                          ),
                          child: TextField(
                            controller: _registrationNumberController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your registration number',
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.015),
                        Text(
                          "Zip Code:",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: screenSize.width * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        Container(
                          height: screenSize.height * 0.068,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                          ),
                          child: TextField(
                            controller: _zipCodeController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your zip code',
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                          ),
                        ),
                      ],
                      if (isWorkerSelected) ...[
                        SizedBox(height: screenSize.height * 0.015),
                        Text(
                          "Employee ID:",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: screenSize.width * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        Container(
                          height: screenSize.height * 0.068,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                          ),
                          child: TextField(
                            controller: _employeeIdController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your employee ID',
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.015),
                        Text(
                          "Area Code:",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: screenSize.width * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        Container(
                          height: screenSize.height * 0.068,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                          ),
                          child: TextField(
                            controller: _areaCodeController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your area code',
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: screenSize.height * 0.02),
                      Center(
                        child: SizedBox(
                          width: screenSize.width * 0.6,
                          height: screenSize.height * 0.06,
                          child: TextButton(
                            onPressed: _showVerificationDialog,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(const Color(0xFF0092D1)),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                                ),
                              ),
                            ),
                            child: Text(
                              "Create",
                              style: TextStyle(
                                fontSize: screenSize.width * 0.042,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                       SizedBox(height: screenSize.height * 0.02),
                    ],
                    
                  ),
                 
                ),
              ),
              Positioned(
                bottom: screenSize.height * 0.05,
                left: screenSize.width * 0.15,
                child: Text(
                  "Already have an account?",
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w600,
                    fontSize: screenSize.width * 0.04,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              Positioned(
                bottom: screenSize.height * 0.046,
                right: screenSize.width * 0.18,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: screenSize.height * 0.03,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 98, 255, 0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
