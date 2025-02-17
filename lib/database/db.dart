import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:NetCure/database/setting.dart';
import 'package:encrypt/encrypt.dart' as cry;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileKey {
  final String email;
  final String pass;
  final iv = cry.IV.fromUtf8('NetCure_Project1');
  String passHash;
  String keyEmail;
  String keyPass;
  ProfileKey(this.email, {this.pass}) {
    keyEmail = crypto.md5.convert(Utf8Encoder().convert(this.email)).toString();
    if (pass != null) {
      keyPass = crypto.md5.convert(Utf8Encoder().convert(this.pass)).toString();
      passHash = enc(
          crypto.sha256.convert(Utf8Encoder().convert(this.pass)).toString(),
          keys: keyEmail);
    }
  }

  String enc(data, {keys}) {
    if (keys == null) keys = keyPass;
    print("ENCRYPTION");
    print("key1:" + keys);
    final key = cry.Key.fromUtf8(keys);
    print("key2:" + key.base16);
    final iv = cry.IV.fromUtf8("netcure_sotware1");
    print("key3:" + iv.toString());
    final encrypter = cry.Encrypter(cry.AES(key));
    print("key4:" + encrypter.toString());
    final encr = encrypter.encrypt(data, iv: iv);
    print("key5:" + encr.base64);
    return encr.base64;
  }

  String dec(data, {keys}) {
    print("DECRYPTION");
    if (keys == null) keys = keyPass;
    print("key1:" + keys);
    final key = cry.Key.fromUtf8(keys);
    print("key2:" + key.base16);
    final iv = cry.IV.fromUtf8("netcure_sotware1");
    print("key3:" + iv.toString());
    final encrypter = cry.Encrypter(cry.AES(key));
    print("key4:" + encrypter.toString());
    final encr = encrypter.decrypt64(data, iv: iv);
    print("key5:" + encr);
    return encr;
  }
}

class Alarms {
  TimeOfDay alarms;
  String name;
  Alarms({this.alarms, this.name = ""});
}

class Routines {
  String name;
  List<Alarms> alarms;
  Routines({this.name});
}

class PersonalData {
  final picker = ImagePicker();
  Uint8List myPhoto;
  DateTime dob;
  int sex;
  List<Routines> routines = [];
  int ethnic;
  List<String> deceases;
  String base64 = "";

  Uint8List get userPhoto {
    return myPhoto = base64Decode(base64);
  }

  Future<bool> updatePhoto() async {
    PickedFile ret = await picker.getImage(source: ImageSource.gallery);
    if (ret != null) {
      final File photos = File(ret.path);
      myPhoto = photos.readAsBytesSync();
      base64 = base64Encode(myPhoto);
      return true;
    } else
      return false;
  }

  String stringify() {
    return "{\"photo\":\"$base64\"}";
  }

  PersonalData({this.base64 = ""});
  factory PersonalData.fromJson(dynamic json) {
    return PersonalData(base64: json['base64']);
  }
}

class ProfileData {
  int age;
  String hints;
  String name;
  String phone;
  String shaPass;
  String email;
  String personalString;
  PersonalData personal = PersonalData();

  ProfileData(
      {this.age,
      this.hints,
      this.name,
      this.phone,
      this.shaPass,
      this.personalString});

  factory ProfileData.fromJson(dynamic json) {
    return ProfileData(
        age: json['age'] as int,
        hints: json['hints'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        shaPass: json['sha_pass'] as String,
        personalString: json['personal'] as String);
  }
}

class ProfileDB {
  ProfileKey key;
  ProfileData data = ProfileData();
  int counter = 0;
  String encMD5(String input) =>
      crypto.md5.convert(Utf8Encoder().convert(input)).toString();
  String db = "https://net-cure.firebaseio.com/";
  Future<String> read(String link) async {
    final resp = await http.get(db + link);
    if (resp.statusCode != 200) {
      print("Error Get Data From $link");
      return null;
    }
    print("Succesfull get data from $link\nResp:${resp.body}");
    return resp.body;
  }

  Future<bool> write(String link, String value) async {
    final resp = await http.put(db + link, body: value);
    if (resp.statusCode != 200) {
      print("Error Write Data From $link\nResp:${resp.body}");
      return false;
    }
    print("Succesfull get data from $link\nResp:${resp.body}");
    return true;
  }

  Future<bool> updatePersonal() async {
    return write("${key.keyEmail}/personal.json",
        "\"" + key.enc(data.personal.stringify()) + "\"");
  }

  Future<int> getLastOnline({String onEmail}) async {
    final resp = await this
        .read(encMD5((onEmail == null) ? data.email : onEmail) + "/age.json");

    if (resp == "null") return 0;
    int maxAge = DateTime(2002).millisecondsSinceEpoch -
        DateTime(2000).millisecondsSinceEpoch;
    int age = DateTime.now().millisecondsSinceEpoch - int.parse(resp);
    print("maximum age:" + maxAge.toString());
    print("profile_age:" + age.toString());
    if (age < maxAge) {
      print("Age is permitted to access");
      return 1;
    } else {
      print("Age has Exceeded, deleting");
      return 2;
    }
  }

  Future<bool> saveSetting(Setting sett) async {
    String resp = "${sett.toJson().toString()}";
    print(resp);
    return await write("${key.keyEmail}/setting.json", "\"${key.enc(resp)}\"");
  }

  Future<Setting> getSetting() async {
    String resp = await read("${key.keyEmail}/setting.json");
    Setting buff = Setting.fromJson(
        jsonDecode(key.dec(resp.substring(1, resp.length - 1))));
    print("Setting Decode Success");
    print("Save Setting : " + (await buff.saveSetting()).toString());
    print("Save Setting Success");
    return buff;
  }

  Future<bool> generate(String name, String phone, String email, String pass,
      String hints) async {
    print("Generating....");
    ProfileKey genKey = ProfileKey(email, pass: pass);
    Setting def = setting;
    String personalString = "{\"base64\":null}";
    print(def.toJson().toString());
    String body = "{\"sha_pass\":\"${genKey.passHash}\"," +
        "\"name\":\"${genKey.enc(name)}\"," +
        "\"phone\":\"${genKey.enc(phone, keys: genKey.keyEmail)}\"," +
        "\"age\":${DateTime.now().millisecondsSinceEpoch}," +
        "\"hints\":\"${genKey.enc(hints, keys: genKey.keyEmail)}\"," +
        "\"personal\":\"${genKey.enc(personalString)}\"," +
        "\"setting\":\"${genKey.enc(def.toJson().toString())}\"}";
    print(body);
    if (await write("${genKey.keyEmail}.json", body)) return true;
    return false;
  }

  Future<bool> matchPass(String email, String pass) async {
    data =
        ProfileData.fromJson(jsonDecode(await read(encMD5(email) + ".json")));
    ProfileKey myKey = ProfileKey(email, pass: pass);
    print("Raw ShaPass: " + data.shaPass);
    print("Sha Saved  : " + myKey.passHash);
    if (myKey.passHash == data.shaPass) {
      print("Password Match");
      data.email = email;
      data.phone = myKey.dec(data.phone, keys: myKey.keyEmail);
      data.hints = myKey.dec(data.hints, keys: myKey.keyEmail);
      data.name = myKey.dec(data.name);
      data.personal =
          PersonalData.fromJson(jsonDecode(myKey.dec(data.personalString)));
      print("${data.personal.base64}");
      key = myKey;
      return true;
    }
    return false;
  }

  Future<bool> getMyHints(String email, String phone) async {
    data =
        ProfileData.fromJson(jsonDecode(await read(encMD5(email) + ".json")));
    ProfileKey myKey = ProfileKey(email);
    print("My Email Key    : ${myKey.keyEmail}");
    data.phone = myKey.dec(data.phone, keys: myKey.keyEmail);
    print("decrypted phone : ${data.phone}");
    if (data.phone == phone) {
      data.hints = myKey.dec(data.hints, keys: myKey.keyEmail);
      return true;
    }
    return false;
  }

  Future<int> login(String email, String pass) async {
    int state = await this.getLastOnline(onEmail: email);
    if (state == 0)
      return 1;
    else if (state == 2)
      return 4;
    else if (state == 1) {
      if (await this.matchPass(email, pass)) {
        return 0;
      } else if (counter > 1)
        return 3;
      else {
        counter++;
        return 2;
      }
    }
    return 5;
  }

  Future<bool> checkMail({String onEmail}) async {
    if (await this.getLastOnline(onEmail: onEmail) == 1) {
      print("Email is registered");
      return true;
    } else {
      print("Email is unregister");
      return false;
    }
  }
}

ProfileDB profile = ProfileDB();
