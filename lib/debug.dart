import 'package:NetCure/database/hospital.dart';
import 'package:NetCure/database/locale.dart';
import 'package:NetCure/dialogboxes.dart';
import 'package:flutter/cupertino.dart';

void onlyForDebug(BuildContext context) async {
  print("return" + (await routineAdd(context).toString()));
}
