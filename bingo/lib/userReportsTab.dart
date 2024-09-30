import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ViewPageResolved.dart';
import 'HomePage.dart';
class ViewUserReportsTab extends StatefulWidget {
  @override
  _ViewUserReportsTabState createState() => _ViewUserReportsTabState();
}

class _ViewUserReportsTabState extends State<ViewUserReportsTab> {
  Map<String, dynamic>? selectedReport;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    fetchUserEmail().then((email) {
      setState(() {
        userEmail = email;
      });
    });
  }

  Future<String?> fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.email;
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
                      selectedReport = null;
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
                  top: screenHeight * 0.13,
                  left: screenWidth * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      HomePage.homePageKey.currentState?.updateSelectedIndex(7);
                    },
                    child: const Text('Create Report'),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.21,
                  left: screenWidth * 0.05,
                  child: Text(
                    "To be Resolved",
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
                    child: userEmail == null
                        ? Center(child: CircularProgressIndicator())
                        : StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('reports')
                                .where('userEmail', isEqualTo: userEmail)
                                .where('isResolved', isEqualTo: false)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              var reports = snapshot.data!.docs;
                              reports.sort((a, b) => a['severity'].compareTo(b['severity']));

                              return SingleChildScrollView(
                                child: Column(
                                  children: List.generate(reports.length, (index) {
                                    var report = reports[index];
                                    return _buildReportItem(report, screenWidth, screenHeight);
                                  }),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.56,
                  left: screenWidth * 0.075,
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
                  top: screenHeight * 0.65,
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
                          .where('userEmail', isEqualTo: userEmail)
                          .where('isResolved', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        var resolvedReports = snapshot.data!.docs;

                        return SingleChildScrollView(
                          child: Column(
                            children: List.generate(resolvedReports.length, (index) {
                              var report = resolvedReports[index];
                              return _buildReportItem(report, screenWidth, screenHeight);
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

  Widget _buildReportItem(DocumentSnapshot report, double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.04),
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
          height: screenHeight * 0.08,
          decoration: BoxDecoration(
            color: const Color(0xffE0FFFF),
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
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
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report['title'],
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: screenWidth * 0.04,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.28,
                  height: screenHeight * 0.04,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBBC05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                    ),
                    onPressed: () {
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: screenHeight * 0.02,
                          color: Colors.white,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          'View',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
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
  }
}

class ViewPage extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onClose;
  final VoidCallback onResolve;

  ViewPage({required this.report, required this.onClose, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
            child: Row(
              children: [
                GestureDetector(
                  child: Image.asset('Images/BackButton.png'),
                  onTap: onClose,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  report['title'],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.09,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.3,
            left: screenWidth * 0.1,
            child: Container(
              width: screenWidth * 0.8,
              height: screenHeight * 0.6,
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: const Color(0xffE0FFFF),
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location:\n${report['location']}',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: screenHeight * 0.025,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Text(
                      'Description:\n${report['description']}',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: screenHeight * 0.025,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Text(
                      'Severity:\n${report['severity']}',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: screenHeight * 0.025,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Image(image: NetworkImage(report['imageUrl'])),
                  ],
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}