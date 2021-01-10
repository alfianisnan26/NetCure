import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlng/latlng.dart';

class RSDBJB {
  String nama; //2
  String alamat; //3
  String kecamatan; //5
  String kelurahan; //4
  String kota; //1
  String phone; //6
  LatLng pos; //7
}

class HospitalPos {
  List<RSDBJB> hospital;

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  void loadHospital() async {
    print("here");
    String resp = await getFileData("assets/database/jabar_hospital.csv");
    List<List<dynamic>> val = const CsvToListConverter().convert(resp);
    print(resp);
    hospital = List<RSDBJB>.generate(val.length - 1, (index) {
      RSDBJB dump = RSDBJB();
      dump.kota = val[index][1];
      dump.nama = val[index][2];
      dump.alamat = val[index][3];
      dump.kelurahan = val[index][4];
      dump.kecamatan = val[index][5];
      dump.phone = val[index][6];
    });
  }
}

HospitalPos hospital = HospitalPos();
