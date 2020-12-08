import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapNew extends StatefulWidget {
  @override
  _MapNewState createState() => _MapNewState();
}

class _MapNewState extends State<MapNew> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final Set<Marker> _markers = {};

  double mapBottomPadding = 250;
  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;

  Position currentPosition;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  static final CameraPosition _myHome = CameraPosition(
    target: LatLng(-6.196690, 106.888430),
    zoom: 14.4746,
  );

  void setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

  void launchDialer(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      print('Could not launch $command');
    }
  }

  @override
  Widget build(BuildContext context) {
    Marker omniHospital = Marker(
      markerId: MarkerId('destination'),
      position: LatLng(-6.17602, 106.88445),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: 'RS Omni Pulomas', snippet: '4,7 km'),
    );

    return Scaffold(
      body: Stack(children: <Widget>[
        GoogleMap(
            // padding: EdgeInsets.only(bottom: mapBottomPadding),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            markers: _markers,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _myHome,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setState(() {
                _markers.add(omniHospital);
              });
              //function to get current location
              setupPositionLocator();
            }),

          Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {
                    launchDialer('tel: +6229779999');
                  },
                  label: Text("Dial"),
                  icon: Icon(Icons.phone),
                  backgroundColor: Colors.green[300],
                ),
              ],
            ),
          ),
      ]),
    );
  }
}
