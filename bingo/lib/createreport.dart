import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:http/http.dart' as http;
import 'HomePage.dart';

class UserReportTab extends StatefulWidget {
  const UserReportTab({Key? key}) : super(key: key);

  @override
  State<UserReportTab> createState() => _UserReportTabState();
}

class _UserReportTabState extends State<UserReportTab> {
  File? image;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String severity = "Medium"; // Default severity value
  bool uploading = false; // Flag to track image upload state
  String? zipCode; // To store retrieved zip code

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final Size screenSize = MediaQuery.of(context).size;
    bool isButtonDisabled =
        image == null; // Disable button if no image is selected

    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: SizedBox(
          height: screenSize.height * 1.5,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: screenSize.height * 0.08,
                left: screenSize.width * 0.8,
                child: GestureDetector(
                  onTap: () {
                      HomePage.homePageKey.currentState?.updateSelectedIndex(2);
                  },
                  child: const Image(
                    image: AssetImage('Images/BackButton.png'),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.08,
                left: screenWidth * 0.05,
                child: Text(
                  "Reports",
                  style: TextStyle(
                    color: Color(0xffF79839),
                    fontSize: screenWidth * 0.12,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.155,
                left: screenWidth * 0.05,
                child: Text(
                  "and earn rewards",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
                    fontFamily: 'Glory',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.21,
                left: screenWidth * 0.05,
                child: Text(
                  "Create a Report",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.09,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.3,
                left: screenWidth * 0.025,
                child: Container(
                  width: screenWidth * 0.95,
                  height: screenHeight * 1, // Adjust height to fit the screen
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: Color(0xffE0FFFF),
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: screenWidth * 0.01,
                        blurRadius: screenWidth * 0.035,
                        offset: Offset(0, screenWidth * 0.02),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Title",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter title',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter description',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      Text(
                        "Severity",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      DropdownButtonFormField<String>(
                        value: severity,
                        items: ["High", "Medium", "Low"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            severity = newValue!;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      Text(
                        "Location",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter location',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFBBC05),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                              ),
                            ),
                            onPressed: () async {
                              final picture = await ImagePicker()
                                  .pickImage(source: ImageSource.camera);
                              if (picture != null) {
                                image = File(picture.path);
                                setState(() {});
                              }
                            },
                            icon: Icon(Icons.camera_alt, color: Colors.white),
                            label: Text(
                              'Camera',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFBBC05),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                              ),
                            ),
                            onPressed: () async {
                              final picture = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (picture != null) {
                                image = File(picture.path);
                                setState(() {});
                              }
                            },
                            icon: Icon(Icons.upload, color: Colors.white),
                            label: Text(
                              'Upload',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: screenHeight * 0.6,
                        left: screenWidth * 0.05,
                        child: image != null
                            ? Container(
                                width: screenWidth * 1,
                                height: screenHeight * 0.2,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(image!),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      uploading
                          ? Center(child: CircularProgressIndicator())
                          : Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xffF79839),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.02),
                                  ),
                                ),
                                onPressed: isButtonDisabled
                                    ? null
                                    : saveReportToFirestore,
                                child: Text(
                                  'File a Report',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.04,
                                  ),
                                ),
                              ),
                            ),
                    
                    ],
                  ),
                ),
              ),
              
            ],
          ),
        )));
  }

Future<void> saveReportToFirestore() async {
  String title = titleController.text.trim();
  String location = locationController.text.trim();
  String description = descriptionController.text.trim();

  if (title.isEmpty || location.isEmpty || description.isEmpty || severity.isEmpty) {
    // Show an error dialog if any of the fields are empty
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Please fill out all fields.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return;
  }

  setState(() {
    uploading = true; // Start showing loader while uploading
  });

  try {
    // Get current user information
    final user = await FirebaseAuth.instance
        .authStateChanges()
        .firstWhere((user) => user != null);

    if (user == null) {
      throw Exception('User not logged in');
    }

    String userEmail = user.email ?? 'Unknown';

    // Geocode the location to get latitude and longitude
    List<geocode.Location> locations =
        await geocode.locationFromAddress(location);
    if (locations.isEmpty) {
      throw Exception('Failed to get coordinates for the provided location');
    }
    double latitude = locations.first.latitude;
    double longitude = locations.first.longitude;

    // Call API to get the Zip Code using latitude and longitude
    zipCode = await fetchZipCode(latitude, longitude);

    // Access Firestore instance and collection
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference reports = firestore.collection('reports');

    // Add a new document with auto-generated ID
    DocumentReference ref = await reports.add({
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'severity': severity,
      'isResolved': false,
      'isSpam': false,
      'location': location,
      'zipCode': zipCode,
      'userEmail': userEmail,
    });

    // Upload image if available
    if (image != null) {
      String fileName =
          '${ref.id}_${DateTime.now().millisecondsSinceEpoch}.png'; // Using Firestore document ID and timestamp
      Reference storageRef =
          FirebaseStorage.instance.ref().child('images/reports/$fileName');
      await storageRef.putFile(image!);

      // Update Firestore document with image URL
      String imageUrl = await storageRef.getDownloadURL();
      await ref.update({'imageUrl': imageUrl});
    }

    // Clear input fields after saving
    titleController.clear();
    locationController.clear();
    descriptionController.clear();
    severity = "Medium"; // Reset severity to default
    image = null;
    zipCode = null; // Reset zip code

    // Show success message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Report filed successfully!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } catch (e) {
    print('Error saving report: $e');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Failed to file report. Please try again.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } finally {
    setState(() {
      uploading = false; // Stop showing loader after uploading
    });
  }
}

  Future<String?> fetchZipCode(double latitude, double longitude) async {
    final String apiUrl =
        'https://bingo-server-gnanasais-projects.vercel.app/get_zip_code'; // Replace with your actual API URL
    final response =
        await http.get(Uri.parse('$apiUrl?lat=$latitude&lng=$longitude'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['zipCode'];
    } else {
      throw Exception('Failed to fetch zip code');
    }
  }
}