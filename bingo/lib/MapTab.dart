import 'package:bingo/mapTabDriver.dart';
import 'package:bingo/MapTabUser.dart';
// import 'package:bingo/mapTabWorker.dart'; // Import your new MapTabWorker widget
import 'package:bingo/mapTabWorker.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth if needed
import 'package:cloud_firestore/cloud_firestore.dart'; // Import FirebaseFirestore if needed

class MapTab extends StatefulWidget {
  const MapTab({Key? key}) : super(key: key);

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  String accountType = ''; // Variable to hold account type fetched from Firestore

  @override
  void initState() {
    super.initState();
    // Fetch accountType from Firestore when the widget initializes
    fetchAccountType();
  }

  Future<void> fetchAccountType() async {
    try {
      // Replace with your method of fetching accountType from Firestore
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          accountType = userDoc['accountType']; // Update accountType from Firestore document
        });
      }
    } catch (error) {
      print('Error fetching account type: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (accountType.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(), // Show a loading indicator while fetching accountType
      );
    } else {
      // Conditional rendering based on accountType
      return Center(
        child: accountType == 'User'
            ? const BinMap() // Widget for 'User'
            : accountType == 'Driver'
            ? const BinMapDriver() // Widget for 'Driver'
            : accountType == 'Worker'
            ? const BinMapWorker() // Widget for 'Worker'
            : Text(
          'Unknown account type: $accountType',
          style: const TextStyle(fontSize: 18),
        ),
      );
    }
  }
}
