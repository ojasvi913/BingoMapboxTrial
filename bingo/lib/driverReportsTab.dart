import 'package:bingo/ViewReportsPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'ViewPageResolved.dart'; // Import your ViewPageResolved implementation

class DriverReportTab extends StatefulWidget {
  const DriverReportTab({Key? key}) : super(key: key);

  @override
  State<DriverReportTab> createState() => _DriverReportTabState();
}

class _DriverReportTabState extends State<DriverReportTab> {
  Map<String, dynamic>? selectedReport; // Track selected report details
  String? driverZipCode; // Store driver's ZIP code

  @override
  void initState() {
    super.initState();
    fetchDriverZipCode().then((zipCode) {
      setState(() {
        driverZipCode = zipCode; // Update the state with the ZIP code
      });
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return selectedReport != null
        ? selectedReport!['isResolved']
            ? ViewPageResolved(
                report: selectedReport!,
                onClose: () {
                  setState(() {
                    selectedReport = null;
                  });
                },
              )
            : ViewPage(
                report: selectedReport!,
                onClose: () {
                  setState(() {
                    selectedReport = null;
                  });
                },
                onResolve: () async {
                  if (selectedReport != null) {
                    await FirebaseFirestore.instance
                        .collection('reports')
                        .doc(selectedReport!['id'])
                        .update({'isResolved': true});
                    setState(() {
                      selectedReport =
                          null; // Clear selected report after resolving
                    });
                  }
                },
                onSpam: () async {
                  if (selectedReport != null) {
                    await FirebaseFirestore.instance
                        .collection('reports')
                        .doc(selectedReport!['id'])
                        .update({'isSpam': true, 'isResolved': "NA"});
                    setState(() {
                      selectedReport =
                          null; // Clear selected report after resolving
                    });
                  }
                },
              )
        : Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Positioned(
                  top: screenHeight * 0.08,
                  left: screenWidth * 0.05,
                  child: Text(
                    "Reports",
                    style: TextStyle(
                      color: const Color(0xffF79839),
                      fontSize: screenWidth * 0.12,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.21,
                  left: screenWidth * 0.05,
                  child: Text(
                    "Resolve",
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
                  left: screenWidth * 0.05,
                  child: Container(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.25,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: const Color(0xffE0FFFF),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 4.0,
                          blurRadius: 8.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: driverZipCode == null
                        ? Center(child: CircularProgressIndicator())
                        : StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('reports')
                                .where('zipCode', isEqualTo: driverZipCode)
                                .where('isResolved',
                                    isEqualTo:
                                        false) // Fetch unresolved reports
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              var reports = snapshot.data!.docs;

                              // Sorting reports based on severity
                              reports.sort((a, b) {
                                int severityA = getSeverityLevel(a['severity']);
                                int severityB = getSeverityLevel(b['severity']);
                                return severityA.compareTo(severityB);
                              });

                              return SingleChildScrollView(
                                child: Column(
                                  children:
                                      List.generate(reports.length, (index) {
                                    var report = reports[index];

                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: screenWidth * 0.04),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedReport = {
                                              'id': report.id,
                                              'title': report['title'],
                                              'description':
                                                  report['description'],
                                              'severity': report['severity'],
                                              'imageUrl': report['imageUrl'],
                                              'location': report['location'],
                                              'isResolved':
                                                  report['isResolved'],
                                            };
                                          });
                                        },
                                        child: Container(
                                          width: screenWidth * 0.8,
                                          height: screenHeight * 0.09,
                                          decoration: BoxDecoration(
                                            color: const Color(0xffE0FFFF),
                                            borderRadius: BorderRadius.circular(
                                                screenWidth * 0.02),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                spreadRadius: 2.0,
                                                blurRadius: 6.0,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                screenWidth * 0.04),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        report['title'],
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontSize:
                                                              screenWidth *
                                                                  0.04,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(
                                                          height: screenWidth *
                                                              0.01), // Add some spacing between title and additional text
                                                      Text(
                                                        "Severity:" +
                                                            report['severity'],
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontSize: screenWidth *
                                                              0.03, // Adjust the font size as needed
                                                          color: Colors
                                                              .grey, // You can change the color as desired
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: screenWidth * 0.28,
                                                  height: screenHeight * 0.04,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFFBBC05),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    screenWidth *
                                                                        0.02),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        selectedReport = {
                                                          'id': report.id,
                                                          'title':
                                                              report['title'],
                                                          'description': report[
                                                              'description'],
                                                          'severity': report[
                                                              'severity'],
                                                          'imageUrl': report[
                                                              'imageUrl'],
                                                          'location': report[
                                                              'location'],
                                                          'isResolved': report[
                                                              'isResolved'],
                                                        };
                                                      });
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.remove_red_eye,
                                                          size: screenHeight *
                                                              0.02,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(
                                                            width: screenWidth *
                                                                0.01),
                                                        Text(
                                                          'View',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.04,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.56,
                  left: screenWidth * 0.05,
                  child: Text(
                    "Resolved",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.09,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight *
                      0.65, // Adjusted position for resolved reports
                  left: screenWidth * 0.05,
                  child: Container(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.25,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: const Color(0xffE0FFFF),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 4.0,
                          blurRadius: 8.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('reports')
                          .where('zipCode', isEqualTo: driverZipCode)
                          .where('isResolved',
                              isEqualTo: true) // Fetch resolved reports
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        var resolvedReports = snapshot.data!.docs;

                        return SingleChildScrollView(
                          child: Column(
                            children:
                                List.generate(resolvedReports.length, (index) {
                              var report = resolvedReports[index];

                              return Padding(
                                padding:
                                    EdgeInsets.only(bottom: screenWidth * 0.04),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedReport = {
                                        'id': report.id,
                                        'title': report['title'],
                                        'description': report['description'],
                                        'severity': report['severity'],
                                        'imageUrl': report['imageUrl'],
                                        'location': report['location'],
                                        'isResolved': report['isResolved'],
                                      };
                                    });
                                  },
                                  child: Container(
                                    width: screenWidth * 0.8,
                                    height: screenHeight * 0.09,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffE0FFFF),
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.02),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2.0,
                                          blurRadius: 6.0,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(screenWidth * 0.04),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  report['title'],
                                                  style: TextStyle(
                                                    fontFamily: 'Roboto',
                                                    fontSize:
                                                        screenWidth * 0.04,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(
                                                    height: screenWidth *
                                                        0.01), // Add some spacing between title and additional text
                                                Text(
                                                  "Severity:" +
                                                      report['severity'],
                                                  style: TextStyle(
                                                    fontFamily: 'Roboto',
                                                    fontSize: screenWidth *
                                                        0.03, // Adjust the font size as needed
                                                    color: Colors
                                                        .grey, // You can change the color as desired
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: screenWidth * 0.28,
                                            height: screenHeight * 0.04,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFFBBC05),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          screenWidth * 0.02),
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  selectedReport = {
                                                    'id': report.id,
                                                    'title': report['title'],
                                                    'description':
                                                        report['description'],
                                                    'severity':
                                                        report['severity'],
                                                    'imageUrl':
                                                        report['imageUrl'],
                                                    'location':
                                                        report['location'],
                                                    'isResolved':
                                                        report['isResolved'],
                                                  };
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.remove_red_eye,
                                                    size: screenHeight * 0.02,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.01),
                                                  Text(
                                                    'View',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          screenWidth * 0.04,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

int getSeverityLevel(String severity) {
  switch (severity) {
    case 'High':
      return 1;
    case 'Medium':
      return 2;
    case 'Low':
      return 3;
    default:
      return 0;
  }
}
