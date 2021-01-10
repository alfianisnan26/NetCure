import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:NetCure/dialogboxes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'locale.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:NetCure/database/db.dart' as db;

class SettingScreen extends StatefulWidget {
  _SettingScreen createState() => _SettingScreen();
}

class _SettingScreen extends State<SettingScreen> {
  BuildContext scaffoldContext;
  bool _tempDarkMode;
  int _tempnewsLocale;
  bool changes = false;
  @override
  void initState() {
    super.initState();
    print("Init State");
    tempNewsCount.value = setting.maximumNewsCountGet();
    tempNewsCount.addListener(() {
      setState(() {});
    });

    _tempDarkMode = setting.theme.darkMode ??= false;
    _tempnewsLocale = setting.newsLocale.used ??= 0;
    ratioMax.value = setting.ratioDrawerMaxHeightGet();
    ratioMin.value = setting.ratioDrawerMinHeightGet();
    ratioMax.addListener(() {
      setState(() {});
    });
    ratioMin.addListener(() {
      setState(() {});
    });
    print(_tempnewsLocale);
  }

  Future<bool> saveSetting() async {
    if (await Setting(
            maximumNewsCount: tempNewsCount.value,
            drawerRow: setting.drawerRow,
            autoPlay: setting.autoPlay,
            autoPlayTime: setting.autoPlayTime,
            ratioDrawerMaxHeight: ratioMax.value,
            ratioDrawerMinHeight: ratioMin.value,
            email: setting.email,
            pass: setting.pass,
            theme: MyTheme(darkMode: setting.theme.darkMode),
            newsLocale: NewsLocale(
                updates:
                    (setting.newsLocale.used != _tempnewsLocale) ? true : false,
                used: _tempnewsLocale))
        .saveSetting()) {
      Scaffold.of(scaffoldContext).showSnackBar(SnackBar(
        content: Text('Setting Saved'),
      ));
      _tempDarkMode = setting.theme.darkMode;
      setting.newsLocale.used = _tempnewsLocale;
      tempNewsCount.value = setting.maximumNewsCountGet();
      return true;
    }

    Scaffold.of(scaffoldContext).showSnackBar(SnackBar(
      content: Text('Failed to save settings'),
    ));
    return false;
  }

  Widget menuSetting(String title, Widget child) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1)),
        height: 70,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), child]));
  }

  Widget menuSeparator(String text) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1)),
        width: setting.screenSize.width,
        height: 15,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(text,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    color: Theme.of(context).primaryColor))));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (_tempDarkMode != setting.theme.darkMode) changes = true;
          if (_tempnewsLocale != setting.newsLocale.used) changes = true;
          if (tempNewsCount.value != setting.maximumNewsCountGet())
            changes = true;
          if (ratioMax.value != setting.ratioDrawerMaxHeightGet())
            changes = true;
          if (ratioMin.value != setting.ratioDrawerMinHeightGet())
            changes = true;
          if (changes) {
            Scaffold.of(scaffoldContext).showSnackBar(SnackBar(
              content: Text('Setting are not saved, continue?'),
              action: SnackBarAction(
                label: 'Yes',
                onPressed: () {
                  if (_tempDarkMode != setting.theme.darkMode)
                    setting.theme.switchTheme(_tempDarkMode);
                  Navigator.pop(context);
                },
              ),
            ));
            return false;
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Settings"),
            actions: [
              Builder(builder: (context) {
                scaffoldContext = context;
                return IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () async {
                      if (await saveSetting()) if (await db.profile
                          .saveSetting(setting)) changes = false;
                    });
              })
            ],
          ),
          body: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              menuSeparator('GENERAL'),
              menuSetting(
                'Languange',
                Text('DropDown'),
              ),
              menuSetting(
                  'Default Notification', Text('Notification Selector')),
              menuSeparator('DISPLAY'),
              menuSetting(
                  'Dark Mode',
                  Switch(
                    value: setting.theme.darkMode,
                    onChanged: (val) {
                      setState(() => setting.theme.switchTheme(val));
                      print(
                          'Trigger Switch $_tempDarkMode and ${setting.theme.darkMode}');
                    },
                  )),
              menuSetting(
                  'CureBar Ratio',
                  MaterialButton(
                      color: Colors.grey.withOpacity(0.5),
                      child: Text(ratioMin.value.toStringAsPrecision(2) +
                          "-" +
                          ratioMax.value.toStringAsPrecision(2)),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SDSlider();
                          }))),
              menuSeparator('NEWS UPDATE'),
              menuSetting(
                  'News Count',
                  MaterialButton(
                      color: Colors.grey.withOpacity(0.5),
                      child: Text(tempNewsCount.value.toString()),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ASlider();
                          }))),
              menuSetting('Update Schedule', Text('DropDown')),
              menuSetting(
                  'News Locale',
                  Container(
                      child: SearchableDropdown.single(
                          displayClearIcon: false,
                          iconSize: 24,
                          closeButton: 'Cancel',
                          hint: 'Select One',
                          searchHint: 'Select One',
                          value: setting.newsLocale.str[_tempnewsLocale],
                          items: setting.newsLocale.generateList(),
                          onChanged: (val) {
                            _tempnewsLocale =
                                setting.newsLocale.str.indexOf(val);
                            print('$val : $_tempnewsLocale');
                          }))),
            ],
          )),
        ));
  }
}

class MyTheme with ChangeNotifier {
  bool darkMode = false;

  MyTheme({this.darkMode = false});

  factory MyTheme.fromJson(dynamic json) {
    return MyTheme(darkMode: json['darkMode'] as bool);
  }

  Map<String, dynamic> toJson() => {'\"darkMode\"': this.darkMode};

  ThemeMode currentTheme() {
    return darkMode ? ThemeMode.dark : ThemeMode.light;
  }

  bool switchTheme(bool mode) {
    darkMode = mode;
    notifyListeners();
    return darkMode;
  }

  ThemeData get(bool isDark) {
    TextTheme txtTheme = (isDark
            ? ThemeData.dark()
            : ThemeData.light()
                .copyWith(appBarTheme: AppBarTheme(color: Colors.purple)))
        .textTheme;
    ColorScheme colorScheme = isDark
        ? ColorScheme.dark()
        : ColorScheme.light().copyWith(primary: Colors.purple);
    var t = ThemeData.from(
            textTheme: GoogleFonts.montserratTextTheme(txtTheme),
            colorScheme: colorScheme)
        .copyWith(
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor:
                    (isDark) ? Colors.grey.shade900 : Colors.purple,
                foregroundColor: Colors.white),
            buttonColor: Colors.purple,
            cursorColor: Colors.purple,
            highlightColor: Colors.purple,
            toggleableActiveColor: Colors.purple);

    return t;
  }
}

class LocalFiles {
  String content;
  String dir;
  LocalFiles({@required this.dir, this.content});
  Future<bool> delete() async {
    final String path = (await getApplicationDocumentsDirectory()).path;
    await File('$path/${this.dir}').delete();
    return true;
  }

  Future<bool> writeLocalFile() async {
    final String path = (await getApplicationDocumentsDirectory()).path;
    final File out =
        await File('$path/${this.dir}').writeAsString(this.content);
    print('Write OK ${out.path}');
    return true;
  }

  Future<bool> readcontent() async {
    try {
      final String path = (await getApplicationDocumentsDirectory()).path;
      File out = File('$path/${this.dir}');
      this.content = await out.readAsString();
      print('Read File OK at ${out.path}\n${this.content}');
      return true;
    } catch (e) {
      print('Read Error : $e');
      return false;
    }
  }
}

class Setting {
  LocalFiles config = LocalFiles(dir: 'config.conf');
  MyTheme theme;
  Size screenSize;
  int maximumNewsCount;
  int drawerRow;
  bool autoPlay;
  int autoPlayTime;
  NewsLocale newsLocale;
  double ratioDrawerMaxHeight, ratioDrawerMinHeight;
  bool thisTrue;
  bool loggedIn;
  String email;
  String pass;

  Setting(
      {this.maximumNewsCount = 5,
      this.drawerRow = 3,
      this.autoPlay = true,
      this.autoPlayTime = 5,
      this.theme,
      this.newsLocale,
      this.thisTrue = false,
      this.ratioDrawerMaxHeight = 0.8,
      this.ratioDrawerMinHeight = 0.2,
      this.email,
      this.pass});

  Setting.fromJson(Map<String, dynamic> json)
      : this.maximumNewsCount = json['maximumNewsCount'],
        this.ratioDrawerMaxHeight = json['rdmaxh'],
        this.ratioDrawerMinHeight = json['rdminh'],
        this.drawerRow = json['drawerRow'],
        this.autoPlay = json['autoPlay'],
        this.autoPlayTime = json['autoPlayTime'],
        this.theme = MyTheme.fromJson(json['MyTheme']),
        this.newsLocale = NewsLocale.fromJson(json['NewsLocale']),
        this.thisTrue = json['ThisTrue'],
        this.email = json['mail'],
        this.pass = json['pass'];

  Map<String, dynamic> toJson() => {
        "\"maximumNewsCount\"": this.maximumNewsCount,
        "\"rdmaxh\"": this.ratioDrawerMaxHeight,
        "\"rdminh\"": this.ratioDrawerMinHeight,
        "\"drawerRow\"": this.drawerRow,
        "\"autoPlay\"": this.autoPlay,
        "\"autoPlayTime\"": this.autoPlayTime,
        "\"MyTheme\"": this.theme.toJson(),
        "\"NewsLocale\"": this.newsLocale.toJson(),
        "\"ThisTrue\"": true,
        "\"mail\"": "\"${this.email}\"",
        "\"pass\"": "\"${this.pass}\""
      };

  Future<Setting> loadSetting() async {
    if (await config.readcontent()) {
      Setting dump = Setting.fromJson(jsonDecode(config.content));
      if (this.thisTrue != null) {
        print('Load Setting Success value :${config.content}');
        return dump;
      }
    }
    return null;
  }

  Future<bool> deleteSession() async {
    return await config.delete();
  }

  Future<bool> saveSetting() async {
    config.content = this.toJson().toString();
    if (await config.writeLocalFile()) {
      print('Save Setting Success value :${config.content}');
      return true;
    }
    return false;
  }

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

  int autoPlayTimeGet() {
    if (autoPlayTime == null) return 5;
    return this.autoPlayTime;
  }

  int maximumNewsCountGet() {
    if (maximumNewsCount == null) return 10;
    return this.maximumNewsCount;
  }
}

Setting setting =
    Setting(theme: MyTheme(darkMode: false), newsLocale: NewsLocale());
