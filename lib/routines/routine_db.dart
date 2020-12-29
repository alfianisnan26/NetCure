import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Medicine {
  String name;
  String type;
  int qty;
  List<DateTime> sched = List();

  Medicine({ this.name='some meds', this.type='pill', this.qty=0, this.sched });
}

class RoutineDatabase {

  Future<void> updateRoutines(String routineName, Medicine medicine) async {
    
    // collection reference
    CollectionReference userRoutines = FirebaseFirestore.instance.collection('routines');
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid;
    return await userRoutines.doc(uid).set({
      'name': routineName,
      'medicine': medicine.name,
      'type': medicine.type,
      'freq': medicine.qty,
      'schedule': FieldValue.arrayUnion(medicine.sched),
    });
  }

}