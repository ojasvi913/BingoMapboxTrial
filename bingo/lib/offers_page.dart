import 'package:flutter/material.dart';

class OffersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenSize.width,
              height: screenSize.height,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: screenSize.width * 0.1,
                    top: screenSize.height * 0.1,
                    child: SizedBox(
                      width: screenSize.width * 0.5,
                      height: screenSize.height * 0.1,
                      child: Text(
                        'Rewards',
                        style: TextStyle(
                          color: Color(0xFFF79839),
                          fontSize: screenSize.width * 0.1,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenSize.width * 0.1,
                    top: screenSize.height * 0.2,
                    child: Text(
                      'Spend your Rewards',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenSize.width * 0.05,
                        fontFamily: 'Glory',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenSize.width * 0.05,
                    top: screenSize.height * 0.3,
                    child: Container(
                      width: screenSize.width * 0.9,
                      height: screenSize.height * 0.5,
                      decoration: ShapeDecoration(
                        color: Color(0xFF6D878F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: screenSize.width * 0.3,
                            top: screenSize.height * 0.1,
                            child: Container(
                              width: screenSize.width * 0.3,
                              height: screenSize.width * 0.3,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('Images/coming_soon.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: screenSize.width * 0.2,
                            top: screenSize.height * 0.33,
                            child: Text(
                              'Coming Soon',
                              style: TextStyle(
                                color: Color(0xFFAEFF89),
                                fontSize: screenSize.width * 0.08,
                                fontFamily: 'Paytone One',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
