import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

class SettingScreen extends StatefulWidget {
  _SettingScreen createState() => _SettingScreen();
}

class _SettingScreen extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget menuSetting(String title, Widget child) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), child]);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SafeArea(
          minimum: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              menuSetting(
                  'Dark Mode',
                  Switch(
                    value: setting.theme.darkMode,
                    onChanged: (val) {
                      setting.theme.switchTheme();
                    },
                  )),
              menuSetting('News Locale',
                  DropdownButton(elevation: 1, items: [], onChanged: (val) {})),
            ],
          )),
    );
  }
}

class MyTheme with ChangeNotifier {
  bool darkMode = false;
  ThemeMode currentTheme() {
    return darkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void switchTheme() {
    darkMode = !darkMode;
    notifyListeners();
  }

  ThemeData get(bool isDark) {
    TextTheme txtTheme =
        (isDark ? ThemeData.dark() : ThemeData.light()).textTheme;
    ColorScheme colorScheme = isDark ? ColorScheme.dark() : ColorScheme.light();
    var t = ThemeData.from(
            textTheme: GoogleFonts.montserratTextTheme(txtTheme),
            colorScheme: colorScheme)
        .copyWith(
            buttonColor: Colors.purple,
            cursorColor: Colors.purple,
            highlightColor: Colors.purple,
            toggleableActiveColor: Colors.purple);

    return t;
  }
}

class LocalFiles {
  LocalFiles();
  Future<bool> writeLocalFile(String data, String dir) async {
    final String path = (await getApplicationDocumentsDirectory()).path;
    File('$path/$dir').writeAsString(data);
    return true;
  }

  Future<String> readcontent(String dir) async {
    try {
      final String path = (await getApplicationDocumentsDirectory()).path;
      String contents = await File('$path/$dir').readAsString();
      return contents;
    } catch (e) {
      return null;
    }
  }
}

class Setting {
  String apikey = "ef725f20d8e14cb08e487f74ac7cfc13//";
  MyTheme theme;
  Size screenSize;
  int maximumNewsCount;
  int drawerRow;
  bool autoPlay;
  Duration autoPlayTime;
  int newsLocale;
  double ratioDrawerMaxHeight, ratioDrawerMinHeight;
  double ratioDrawerMaxHeightGet() {
    if (ratioDrawerMaxHeight == null) return 0.8;
    return ratioDrawerMaxHeight;
  }

  int drawerRowGet() {
    if (drawerRow == null) return 3;
    return drawerRow;
  }

  double ratioDrawerMinHeightGet() {
    if (ratioDrawerMinHeight == null)
      return 0.20;
    else if ((screenSize.height * ratioDrawerMinHeight) < 80)
      return screenSize.height / 80;
    return ratioDrawerMinHeight;
  }

  bool autoPlayGet() {
    if (autoPlay == null) return true;
    return this.autoPlay;
  }

  Duration autoPlayTimeGet() {
    if (autoPlayTime == null) return Duration(seconds: 5);
    return this.autoPlayTime;
  }

  int maximumNewsCountGet() {
    if (maximumNewsCount == null) return 5;
    return this.maximumNewsCount;
  }

  void init() {
    theme = MyTheme();
  }
}

Setting setting = Setting();
