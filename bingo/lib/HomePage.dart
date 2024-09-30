import 'package:bingo/HomeTab.dart';
import 'package:bingo/MapTab.dart';
import 'package:bingo/ReportTab.dart';
import 'package:bingo/createreport.dart';
import 'package:bingo/offers_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'SignupPage.dart'; // Import your SignupPage.dart file
import 'UpdateProfile.dart';

class HomePage extends StatefulWidget {
  static final GlobalKey<_HomePageState> homePageKey =
      GlobalKey<_HomePageState>();
  HomePage({Key? key}) : super(key: homePageKey);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedImageIndex = 0; // Track the index of the selected image
  String? driverZipCode;
  late User loggedInUser; // Variable to hold logged-in user details
  late DocumentSnapshot
      userDoc; // Variable to hold user document from Firestore
  int reportCount = 0;
  int pointcount = 0;

  @override
  void initState() {
    super.initState();

    // Get the currently logged-in user
    loggedInUser = FirebaseAuth.instance.currentUser!;
    fetchUserDoc();

    fetchDriverZipCode().then((zipCode) {
      setState(() {
        driverZipCode = zipCode; // Update the state with the ZIP code
      });
    });
  }

  void updateSelectedIndex(int index) {
    setState(() {
      selectedImageIndex = index;
    });
  }

  Future<String?> fetchDriverZipCode() async {
    User? user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        return data?['zipCode']; // Replace with the actual field name
      }
    }
    return null;
  }

  void fetchUserDoc() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(loggedInUser.uid)
        .snapshots()
        .listen((doc) {
      setState(() {
        userDoc = doc;
      });
      fetchReportCount(doc['email']);
    });
  }

  // Fetch user document from Firestore using the UID
  void fetchReportCount(String userEmail) {
    if (userDoc['accountType'] == 'User') {
      FirebaseFirestore.instance
          .collection('reports')
          .where('userEmail', isEqualTo: userEmail)
          .snapshots()
          .listen((querySnapshot) {
        setState(() {
          reportCount = querySnapshot.docs.length;
          pointcount = reportCount * 10;
        });
      });
    }
    if (userDoc['accountType'] == 'Driver') {
      FirebaseFirestore.instance
          .collection('reports')
          .where('isResolved', isEqualTo: true)
          .where('zipCode', isEqualTo: driverZipCode)
          .where('isSpam', isEqualTo: false)
          .snapshots()
          .listen((querySnapshot) {
        setState(() {
          reportCount = querySnapshot.docs.length;
          pointcount = reportCount * 10;
        });
      });
    }
  }

  String getAccountType() {
    if (userDoc != null && userDoc['accountType'] != null) {
      return userDoc['accountType'];
    }
    return 'Loading...'; // Default to 'user' if accountType is not set
  }

  Future<void> addFieldToExistingDocument(
      String documentId, String userEmail) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');

    // Reference to the existing document
    DocumentReference ref = users.doc(documentId);

    // Update the document to add a new field
    await ref.update({
      'No of Reports': reportCount,
    }).catchError((error) {
      print("Failed to update document: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;

    // Calculate responsive positioning and size
    double textTopPadding = screenSize.height * 0.1;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xffFFFFFF),
      body: Stack(
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: textTopPadding, // Top space before text
                ),
                if (selectedImageIndex == 0)
                  Home(
                    screenSize: screenSize,
                    reportCount: pointcount,
                  ),
              ],
            ),
          ),
          Center(
            child: selectedImageIndex ==
                    1 // Assuming selectedImageIndex 5 is for "User.png"
                ? const MapTab()
                : Container(), // Empty container if selectedImageIndex is not 5
          ),
          Center(
            child: selectedImageIndex ==
                    2 // Assuming selectedImageIndex 5 is for "User.png"
                ? const ReportTab()
                : Container(), // Empty container if selectedImageIndex is not 5
          ),
          Center(
            child: selectedImageIndex ==
                    6 // Assuming selectedImageIndex 5 is for "User.png"
                ? UpdateProfile(
                    screenSize: screenSize,
                  )
                : Container(), // Empty container if selectedImageIndex is not 5
          ),
          Center(
            child: selectedImageIndex ==
                    4 // Assuming selectedImageIndex 5 is for "User.png"
                ? OffersPage()
                : Container(), // Empty container if selectedImageIndex is not 5
          ),
          Center(
            child: selectedImageIndex == 7 ? UserReportTab() : Container(),
          ),
          Center(
            child: selectedImageIndex ==
                    5 // Assuming selectedImageIndex 5 is for "User.png"
                ? SingleChildScrollView(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile information
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenSize.height * 0.05,
                          left: screenSize.width * 0.08,
                        ),
                        child: SizedBox(
                          width: screenSize.width * 0.4,
                          child: Text(
                            "BinGo",
                            style: TextStyle(
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold,
                              fontSize: screenSize.width *
                                  0.1, // Responsive font size
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: screenSize.height * 0.02,
                            horizontal: screenSize.width * 0.39),
                        child: SizedBox(
                          width: screenSize.width * 0.4,
                          child: Text(
                            "Profile",
                            style: TextStyle(
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold,
                              fontSize: screenSize.width *
                                  0.06, // Responsive font size
                            ),
                          ),
                        ),
                      ),
                      CustomContainer(
                          height: screenSize.height * 0.46,
                          screenSize: screenSize,
                          children: [
                            if (userDoc != null)
                              Padding(
                                padding: EdgeInsets.only(
                                    top: screenSize.height * 0.02,
                                    left: screenSize.height * 0.045),
                                child: SizedBox(
                                  width: screenSize.width * 0.4,
                                  child: Text(
                                    "Username:",
                                    style: TextStyle(
                                      fontFamily: 'Jost',
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenSize.width *
                                          0.05, // Responsive font size
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: screenSize.height * 0,
                                  left: screenSize.height * 0.045),
                              child: SizedBox(
                                width: screenSize.width * 0.5,
                                child: Text(
                                  "${userDoc['name']}",
                                  style: TextStyle(
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.normal,
                                    fontSize: screenSize.width *
                                        0.05, // Responsive font size
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: screenSize.height * 0.016,
                                  left: screenSize.height * 0.045),
                              child: SizedBox(
                                width: screenSize.width * 0.4,
                                child: Text(
                                  "Email:",
                                  style: TextStyle(
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenSize.width *
                                        0.05, // Responsive font size
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: screenSize.height * 0,
                                  left: screenSize.height * 0.045),
                              child: SizedBox(
                                width: screenSize.width * 0.6,
                                child: Text(
                                  "${userDoc['email']}",
                                  style: TextStyle(
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.normal,
                                    fontSize: screenSize.width *
                                        0.05, // Responsive font size
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: screenSize.height * 0.016,
                                  left: screenSize.height * 0.045),
                              child: SizedBox(
                                width: screenSize.width * 0.6,
                                child: Text(
                                  "No of Reports:",
                                  style: TextStyle(
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenSize.width *
                                        0.05, // Responsive font size
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: screenSize.height * 0.016,
                                  left: screenSize.height * 0.045),
                              child: SizedBox(
                                width: screenSize.width * 0.6,
                                child: Text(
                                  reportCount.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Jost',
                                    fontSize: screenSize.width *
                                        0.05, // Responsive font size
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: screenSize.height * 0.016,
                                  left: screenSize.height * 0.045),
                              child: SizedBox(
                                width: screenSize.width * 0.6,
                                child: Text(
                                  "Account Type:",
                                  style: TextStyle(
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenSize.width *
                                        0.05, // Responsive font size
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: screenSize.height * 0,
                                  left: screenSize.height * 0.045),
                              child: SizedBox(
                                width: screenSize.width * 0.4,
                                child: Text(
                                  "${getAccountType()}",
                                  style: TextStyle(
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.normal,
                                    fontSize: screenSize.width *
                                        0.05, // Responsive font size
                                  ),
                                ),
                              ),
                            ),
                          ]),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      CustomContainer(
                          height: screenSize.height * 0.2,
                          screenSize: screenSize,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: screenSize.height * 0.02,
                                  left: screenSize.width * 0.1),
                              child: Row(
                                children: [
                                  Text(
                                    pointcount.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: screenSize.width * 0.1,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                          255, 15, 191, 38),
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          20), // Add some space between "0" and "points"
                                  Text(
                                    "points",
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: screenSize.width * 0.06,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenSize.width * 0.15),
                              child: SizedBox(
                                width: screenSize.width * 0.6,
                                height: screenSize.height * 0.06,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedImageIndex =
                                          4; // Assuming 6 is the index for Update Profile tab
                                    });
                                    ;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        const Color.fromARGB(255, 255, 153, 1)),
                                    foregroundColor:
                                        WidgetStateProperty.all(Colors.white),
                                    padding: WidgetStateProperty.all(
                                      EdgeInsets.symmetric(
                                          vertical: screenSize.height * 0.015),
                                    ),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            screenSize.width * 0.02),
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "View Offers",
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.049,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenSize.height * 0.01,
                            left: screenSize.width * 0.18),
                        child: SizedBox(
                          width: screenSize.width * 0.4,
                          child: Text(
                            "Settings",
                            style: TextStyle(
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold,
                              fontSize: screenSize.width *
                                  0.06, // Responsive font size
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.15),
                        child: Container(
                          width: screenSize.width * 0.8,
                          height: screenSize.height * 0.06,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 152, 152, 152),
                                spreadRadius: 3,
                                blurRadius: 4,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                selectedImageIndex =
                                    6; // Assuming 6 is the index for Update Profile tab
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Color(0xffAFFF89)),
                              foregroundColor:
                                  WidgetStateProperty.all(Colors.white),
                              padding: WidgetStateProperty.all(
                                EdgeInsets.symmetric(
                                    vertical: screenSize.height * 0.015),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      screenSize.width * 0.02),
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Update Profile",
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.04,
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromARGB(255, 147, 15, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.15),
                        child: Container(
                          width: screenSize.width * 0.8,
                          height: screenSize.height * 0.06,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 152, 152, 152),
                                spreadRadius: 3,
                                blurRadius: 4,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignupPage()),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Color(0xffAFFF89)),
                              foregroundColor:
                                  WidgetStateProperty.all(Colors.white),
                              padding: WidgetStateProperty.all(
                                EdgeInsets.symmetric(
                                    vertical: screenSize.height * 0.015),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      screenSize.width * 0.02),
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Sign out",
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.04,
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromARGB(255, 147, 15, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignupPage()),
                            );
                          },
                          child: const Text('Logout'),
                        ),
                      ),
                      SizedBox(height: 20)
                    ],
                  ))
                : Container(), // Empty container if selectedImageIndex is not 5
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenSize.height * 0.08, // Adjust container height
              width: screenSize.width,
              decoration: const BoxDecoration(color: Color(0xffAFFF89)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(width: screenSize.width * 0.02),
                  _buildImageWithSelectableBackground(
                    'Images/Home.png',
                    0,
                    screenSize.height * 0.12,
                    screenSize.width * 0.12,
                    screenSize.height * 0.12,
                  ),
                  SizedBox(width: screenSize.width * 0.03),
                  _buildImageWithSelectableBackground(
                    'Images/Location.png',
                    1,
                    screenSize.height * 0.12,
                    screenSize.width * 0.12,
                    screenSize.height * 0.12,
                  ),
                  SizedBox(width: screenSize.width * 0.03),
                  _buildImageWithSelectableBackground(
                    'Images/Megaphone.png',
                    2,
                    screenSize.height * 0.12,
                    screenSize.width * 0.12,
                    screenSize.height * 0.12,
                  ),
                  SizedBox(width: screenSize.width * 0.03),
                  _buildImageWithSelectableBackground(
                    'Images/Discount.png',
                    4,
                    screenSize.height * 0.12,
                    screenSize.width * 0.12,
                    screenSize.height * 0.12,
                  ),
                  SizedBox(width: screenSize.width * 0.03),
                  _buildImageWithSelectableBackground(
                    'Images/User.png',
                    5,
                    screenSize.height * 0.12,
                    screenSize.width * 0.12,
                    screenSize.height * 0.12,
                  ),
                  SizedBox(width: screenSize.width * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithSelectableBackground(
      String imagePath, int index, double height, double width, double radius) {
    bool isSelected = selectedImageIndex == index;
    if (index == 5 && selectedImageIndex == 6) {
      isSelected = true;
    }
    if (index == 2 && selectedImageIndex == 7) {
      isSelected = true;
    }
    return GestureDetector(
      onTap: () {
        // Update selected image index when tapped
        HomePage.homePageKey.currentState?.updateSelectedIndex(index);
      },
      child: Container(
        margin: const EdgeInsets.all(8.0), // Adjust margin as needed
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xffE0FFFF) : Colors.transparent,
        ),
        child: Image.asset(
          imagePath,
          height: height,
        ),
      ),
    );
  }
}
