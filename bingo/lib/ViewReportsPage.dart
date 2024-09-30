import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewPage extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onClose;
  final VoidCallback onResolve;
  final VoidCallback onSpam;

  const ViewPage({
    required this.report,
    required this.onClose,
    required this.onResolve,
    required this.onSpam,
    Key? key,
  }) : super(key: key);

  Future<void> _launchMap() async {
    final location = report['location']; // Assuming this is a string like "City, State"
    final url = 'https://www.google.com/maps/search/?api=1&query=$location';
    
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

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
                    Image(image: NetworkImage('${report['imageUrl']}')),
                    SizedBox(height: screenHeight * 0.05),
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.53,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFFF79839),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            ),
                          ),
                          onPressed: _launchMap, // Call the navigation function
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                            child: Text(
                              'Navigate',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.53,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFFF79839),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            ),
                          ),
                          onPressed: onResolve, // Call the resolve callback
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                            child: Text(
                              'Mark as Resolved',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.53,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFFF79839),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            ),
                          ),
                          onPressed: onSpam, // Call the resolve callback
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                            child: Text(
                              'Mark as Spam',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
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
