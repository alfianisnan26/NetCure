import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:re_netcure/hospital/hospitalmap.dart';
import 'package:flutter/material.dart';

final dummySnapshot = [
  {"name": "RS Omni Pulomas", "address": "Jl Cumi", "phone": "0812"},
  {"name": "RSUP Persahabatan", "address": "Jl Beton", "phone": "0812"},
  {"name": "RS Mitra Keluarga", "address": "Jl Locis", "phone": "0812"},
  {"name": "RS Harapan Bunda", "address": "Jl Gembok", "phone": "0812"},
  {"name": "RS Dharma Nugraha", "address": "Jl Linggis", "phone": "0812"},
];

class HospitalList extends StatefulWidget {
  @override
  _HospitalList createState() {
    return _HospitalList();
  }
}

class _HospitalList extends State<HospitalList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospitals Nearby'),
        backgroundColor: Color.fromRGBO(99, 219, 167, 1),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('locations').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListTile(
              title: Text(
                record.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(record.address),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapNew(
                      geoPoint: record.geoPoint,
                      name: record.name,
                      distance: record.distance,
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class Record {
  final String name;
  final String address;
  final String phone;
  final String distance;
  final GeoPoint geoPoint;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['address'] != null),
        assert(map['phone'] != null),
        assert(map['geopoint'] != null),
        assert(map['distance'] != null),
        name = map['name'],
        address = map['address'],
        phone = map['phone'],
        geoPoint = map['geopoint'],
        distance = map['distance'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);
}
