import 'package:NetCure/emergency/maps.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong/latlong.dart';

class RSDBJB {
  String jenis;
  String nama; //2
  String alamat; //3
  String kecamatan; //5
  String kelurahan; //4
  String kota; //1
  String phone; //6
  double lat;
  double lng;
  Duration est = Duration();
  double radius = double.maxFinite;
}

class HospitalPos {
  List<RSDBJB> hospital;

  void sortRadius() {
    int a = 0;
    Distance dist = Distance();
    hospital.forEach((element) {
      if (hospital[a].lat != null &&
          hospital[a].lng != null &&
          !(hospital[a].lat < -90) &&
          !(hospital[a].lat > 90)) {
        hospital[a].radius = dist.as(
            LengthUnit.Kilometer,
            LatLng(hospital[a].lat, hospital[a].lng),
            LatLng(maps.pos.latitude, maps.pos.longitude));
        hospital[a].est =
            Duration(seconds: (hospital[a].radius / (0.013)).round());
        print(hospital[a].radius);
      }
      a++;
    });
    hospital.sort((a, b) => a.radius.compareTo(b.radius));
    hospital.forEach((element) {
      print(element.radius);
    });
  }

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  String toLetterCase(String input) {
    if (input.length <= 1) return input;
    input = input.toLowerCase();
    List<String> list = input.split(" ");
    String out = "";
    list.forEach((element) {
      if (element.length < 1)
        out = element;
      else if (element == "rsud" ||
          element == "rs" ||
          element == "tni" ||
          element == "rsu" ||
          element == "rsd" ||
          element == "pmi" ||
          element == "rsj") {
        out += element.toUpperCase() + " ";
      } else
        out +=
            element.substring(0, 1).toUpperCase() + element.substring(1) + " ";
    });
    out.substring(0, out.length - 1);
    return out;
  }

  void loadHospital() async {
    print("here");
    String resp = await getFileData("assets/database/jabar_hospital.csv");
    List<List<dynamic>> val = const CsvToListConverter().convert(resp);
    print(resp);
    hospital = List<RSDBJB>.generate(val.length - 1, (index) {
      RSDBJB dump = RSDBJB();
      dump.kota = toLetterCase(val[index][1]);
      dump.nama = toLetterCase(val[index][2]);
      int pos = dump.nama.indexOf(" ");
      dump.jenis = dump.nama.substring(0, pos);
      dump.nama = dump.nama.substring(pos + 1);
      dump.alamat = toLetterCase(val[index][3]);
      dump.kelurahan = toLetterCase(val[index][4]);
      dump.kecamatan = toLetterCase(val[index][5]);
      dump.phone = (val[index][6]).toString();
      dump.lat = double.tryParse(val[index][7].toString());
      dump.lng = double.tryParse(val[index][8].toString());
      return dump;
    });
    hospital.removeAt(0);
  }
}

HospitalPos hospital = HospitalPos();
