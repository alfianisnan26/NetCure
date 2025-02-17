import 'package:NetCure/database/hospital.dart';
import 'package:NetCure/database/setting.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';

class MapsPassing {
  Position pos;
  ValueNotifier<int> forLoc = ValueNotifier(0);

  Future<Position> updatePos() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
    pos = await Geolocator.getCurrentPosition();
    print(pos.latitude);
    print(pos.longitude);
    hospital.sortRadius();
    return pos;
  }
}

MapsPassing maps = MapsPassing();

class SmallMaps extends StatefulWidget {
  @override
  _MPSS createState() => _MPSS();
}

class _MPSS extends State<SmallMaps> {
  final controller = MapController(
    location: LatLng(maps.pos.latitude, maps.pos.longitude),
  );
  String alamat = "Please select the card bellow";
  @override
  void initState() {
    maps.forLoc.addListener(() {
      setState(() {
        alamat = hospital.hospital[maps.forLoc.value].alamat +
            "\n" +
            hospital.hospital[maps.forLoc.value].kelurahan +
            ", " +
            hospital.hospital[maps.forLoc.value].kecamatan +
            ", " +
            hospital.hospital[maps.forLoc.value].kota +
            "\n" +
            hospital.hospital[maps.forLoc.value].kecamatan;
      });
      _goto(hospital.hospital[maps.forLoc.value].lat,
          hospital.hospital[maps.forLoc.value].lng);
    });
    super.initState();
  }

  void _goto(double lat, double long) {
    controller.center = LatLng(lat, long);
  }

  void _zoomIn() {
    controller.zoom += 0.25;
    print(controller.zoom);
  }

  void _zoomOut() {
    controller.zoom -= 0.25;
    print(controller.zoom);
  }

  @override
  Widget build(BuildContext context) {
    //final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    //controller.tileSize = 256 / devicePixelRatio;

    return Scaffold(
        body: Stack(
          children: [
            Map(
              controller: controller,
              builder: (context, x, y, z) {
                final url =
                    'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';

                return CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                );
              },
            ),
            Center(
              child: Icon(Icons.close, color: Colors.red),
            ),
            Container(
              width: setting.screenSize.width,
              padding: EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.black26,
                  child: Text(
                    alamat,
                    overflow: TextOverflow.fade,
                    maxLines: 4,
                    softWrap: true,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            )
          ],
        ),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              _zoomOut();
            },
            tooltip: 'Zoom Out',
            child: Icon(Icons.zoom_out),
          ),
          SizedBox(
            height: 5,
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              _zoomIn();
            },
            tooltip: 'Zoom In',
            child: Icon(Icons.zoom_in),
          ),
          SizedBox(
            height: 5,
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              MapsLauncher.launchCoordinates(
                  controller.center.latitude, controller.center.longitude);
            },
            tooltip: 'Open in maps',
            child: Icon(Icons.exit_to_app_rounded),
          ),
        ]));
  }
}
