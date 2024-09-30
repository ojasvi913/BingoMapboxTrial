import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class BinMapWorker extends StatefulWidget {
  const BinMapWorker({Key? key}) : super(key: key);

  @override
  State<BinMapWorker> createState() => _BinMapWorkerState();
}

class _BinMapWorkerState extends State<BinMapWorker> {
  late Future<void> _mapFuture = Future.value();
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];
  final List<LatLng> _waypoints = [];
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(0, 0), // Default value, will be updated later
    zoom: 17,
  );

  LocationData? _currentLocation;
  final Location _location = Location();
  String? _workerAreacode;
  bool _firstLocationUpdate = true;

  @override
  void initState() {
    super.initState();
    _mapFuture = _initialize();
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
    await Firebase.initializeApp();
    _loadMarkersFromFirestore();
  }

  Future<void> _loadMarkersFromFirestore() async {
    _workerAreacode = await _getWorkerAreacode();
    if (_workerAreacode == null) {
      print('Failed to retrieve driver ZIP code');
      return;
    }
    print('Worker Code: $_workerAreacode');

    FirebaseFirestore.instance
        .collection('bin_data')
        .where('areacode', isEqualTo: _workerAreacode)
        .snapshots()
        .listen((snapshot) {
      _markers.clear();
      _waypoints.clear();

      for (var doc in snapshot.docs) {
        double lat = doc['latitude'];
        double lng = doc['longitude'];
        int fillPercent = doc['fill_percent'];

        if (fillPercent > 40) {
          _waypoints.add(LatLng(lat, lng));
        }

        String markerImage;
        if (fillPercent <= 40) {
          markerImage = 'Images/GreenMarker.png';
        } else if (fillPercent <= 60) {
          markerImage = 'Images/YellowMarker.png';
        } else {
          markerImage = 'Images/RedMarker.png';
        }

        getBytesFromAssets(markerImage, calculateMarkerWidth(fillPercent))
            .then((markerIconBytes) {
          final BitmapDescriptor markerIcon =
              BitmapDescriptor.fromBytes(markerIconBytes);

          final marker = Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            icon: markerIcon,
          );
          _markers.add(marker);

          setState(() {});
        });
      }
    });
  }

  Future<String?> _getWorkerAreacode() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in');
        return null;
      }
      String userId = user.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      return userDoc['areacode'];
    } catch (e) {
      print('Error retrieving worker ZIP code: $e');
      return null;
    }
  }

  int calculateMarkerWidth(int fillPercent) {
    return 50;
  }

  Future<Uint8List> getBytesFromAssets(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await _location.getLocation();
    if (_currentLocation != null) {
      setState(() {
        _initialCameraPosition = CameraPosition(
          target:
              LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          zoom: 17,
        );
      });
    }

    _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
        _updateCameraPosition();
      });
    });
  }

  Future<void> _updateCameraPosition() async {
    final GoogleMapController controller = await _controller.future;
    if (_currentLocation != null && _firstLocationUpdate) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
            ),
            zoom: 17,
          ),
        ),
      );
      _firstLocationUpdate = false;
    }
  }

  Future<void> _startNavigation() async {
    if (_currentLocation == null || _waypoints.isEmpty) return;

    LatLng origin =
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    LatLng destination = origin;

    _launchGoogleMaps(origin, destination, _waypoints);
  }

  Future<void> _launchGoogleMaps(
      LatLng origin, LatLng destination, List<LatLng> waypoints) async {
    String originString = '${origin.latitude},${origin.longitude}';
    String destinationString =
        '${destination.latitude},${destination.longitude}';
    String waypointsString = waypoints
        .map((waypoint) => '${waypoint.latitude},${waypoint.longitude}')
        .join('|');

    String url =
        'https://www.google.com/maps/dir/?api=1&origin=$originString&destination=$destinationString&waypoints=$waypointsString&travelmode=driving';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<void>(
        future: _mapFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    _updateCameraPosition();
                  },
                  myLocationEnabled: true,
                  markers: Set<Marker>.of(_markers),
                  myLocationButtonEnabled: false,
                ),
                Positioned(
                  bottom: 80,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _startNavigation,
                    child: const Icon(Icons.navigation),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text('Error loading map'),
            );
          }
        },
      ),
    );
  }
}