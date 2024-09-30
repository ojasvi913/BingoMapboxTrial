import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class BinMap extends StatefulWidget {
  const BinMap({Key? key}) : super(key: key);

  @override
  State<BinMap> createState() => _BinMapState();
}

class _BinMapState extends State<BinMap> {
  late Future<void> _mapFuture = Future.value();
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];
  bool _cameraUpdateAllowed = true;

  CameraPosition? _initialCameraPosition;
  LocationData? _currentLocation;
  final Location _location = Location();

  Future<void> _loadMarkersFromFirestore() async {
    await Firebase.initializeApp();

    FirebaseFirestore.instance
        .collection('bin_data')
        .where('bin_id', isGreaterThan: 0)
        .snapshots()
        .listen((snapshot) {
      _markers.clear();

      for (var doc in snapshot.docs) {
        double lat = doc['latitude'];
        double lng = doc['longitude'];
        int fillPercent = doc['fill_percent'];

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
            infoWindow: InfoWindow(
              title: 'Fill Percentage: $fillPercent%',
              snippet: 'Tap to navigate',
              onTap: () {
                _navigateToMarker(LatLng(lat, lng));
              },
            ),
          );
          _markers.add(marker);
          setState(() {});
        });
      }
    });
  }

  int calculateMarkerWidth(int fillPercent) {
    return 50; // Fixed width; adjust if needed
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) {
      _mapFuture = _loadMap();
      _loadMarkersFromFirestore();
    });
  }

  Future<void> _loadMap() async {
    await Future.delayed(const Duration(seconds: 2));
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
      _initialCameraPosition = CameraPosition(
        target:
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        zoom: 17,
      );
      _updateCameraPosition();
    }

    _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
        if (_cameraUpdateAllowed) {
          _updateCameraPosition();
        }
      });
    });
  }

  Future<void> _updateCameraPosition() async {
    final GoogleMapController controller = await _controller.future;
    if (_currentLocation != null) {
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
      // Allow camera update only once unless user navigates to a different position
      _cameraUpdateAllowed = false;
    }
  }

  Future<void> _navigateToMarker(LatLng markerPosition) async {
    if (_currentLocation != null) {
      final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${_currentLocation!.latitude},${_currentLocation!.longitude}&destination=${markerPosition.latitude},${markerPosition.longitude}&travelmode=driving',
      );

      if (await canLaunch(googleMapsUrl.toString())) {
        await launch(googleMapsUrl.toString());
      } else {
        throw 'Could not launch $googleMapsUrl';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<void>(
        future: _mapFuture,
        builder: (context, snapshot) {
          if (_currentLocation == null) {
            return const Center(
              child:
                  CircularProgressIndicator(), // Loading until location is available
            );
          } else {
            return GoogleMap(
              initialCameraPosition: _initialCameraPosition!,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationEnabled: true,
              markers: Set<Marker>.of(_markers),
              onTap: (_) {
                _closeInfoWindow();
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _closeInfoWindow() async {
    final GoogleMapController controller = await _controller.future;
    controller.hideMarkerInfoWindow(MarkerId(''));
  }
}
