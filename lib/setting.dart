//import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'locale.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class SettingScreen extends StatefulWidget {
  _SettingScreen createState() => _SettingScreen();
}

class _SettingScreen extends State<SettingScreen> {
  BuildContext scaffoldContext;
  bool _tempDarkMode;
  int _tempnewsLocale;

  @override
  void initState() {
    super.initState();
    _tempDarkMode = setting.theme.darkMode ??= false;
    _tempnewsLocale = setting.newsLocale.used ??= 0;
    print(_tempnewsLocale);
  }

  Future<bool> saveSetting() async {
    if (setting.newsLocale.used != _tempnewsLocale) {
      setting.newsLocale.used = _tempnewsLocale;
      setting.newsLocale.updates = true;
    }
    /*
    if (await Config.saveSettings()) {
      _tempDarkMode = setting.theme.darkMode;

      Scaffold.of(scaffoldContext).showSnackBar(SnackBar(
        content: Text('Settings saved'),
      ));
      if (setting.newsLocale.updates)
        Scaffold.of(scaffoldContext).showSnackBar(SnackBar(
          content: Text('You must restart the application'),
          action: SnackBarAction(
            label: 'Restart',
            onPressed: () {},
          ),
        ));
      return true;
    }
    */
    Scaffold.of(scaffoldContext).showSnackBar(SnackBar(
      content: Text('Failed to save settings'),
    ));
    return false;
  }

  Widget menuSetting(String title, Widget child) {
    return Container(
        height: 50,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), child]));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          bool changes = false;
          if (_tempDarkMode != setting.theme.darkMode) changes = true;
          if (_tempnewsLocale != setting.newsLocale.used) changes = true;
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
                      icon: Icon(Icons.check), onPressed: () => saveSetting());
                })
              ],
            ),
            body: SingleChildScrollView(
                child: Container(
              child: SafeArea(
                  minimum: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      menuSetting(
                        'Languange',
                        Text('DropDown'),
                      ),
                      menuSetting('Maximum CureBar Ratio', Text('Slider')),
                      menuSetting('Minimum CureBar Ratio', Text('Slider')),
                      menuSetting('News Count', Text('Slider')),
                      menuSetting('News Update', Text('DropDown')),
                      menuSetting('Default Notification',
                          Text('Notification Selector')),
                      menuSetting(
                          'Dark Mode',
                          Switch(
                            value: setting.theme.darkMode,
                            onChanged: (val) {
                              setting.theme.switchTheme(val);
                              print(
                                  'Trigger Switch $_tempDarkMode and ${setting.theme.darkMode}');
                            },
                          )),
                      menuSetting(
                          'News Locale',
                          SearchableDropdown.single(
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
                              })),
                    ],
                  )),
            ))));
  }
}

class MyTheme with ChangeNotifier {
  bool darkMode = false;

  MyTheme({this.darkMode = false});
/*
  factory MyTheme.fromJson(dynamic json) {
    return MyTheme(darkMode: json['darkMode'] as bool);
  }
*/
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
  MyTheme theme;
  Size screenSize;
  int maximumNewsCount;
  int drawerRow;
  bool autoPlay;
  Duration autoPlayTime;
  NewsLocale newsLocale = NewsLocale();
  double ratioDrawerMaxHeight, ratioDrawerMinHeight;
  /*
  Setting({this.newsLocale, this.theme});
  factory Setting.fromJson(dynamic json) {
    return Setting(
        theme: MyTheme.fromJson(json['MyTheme']),
        newsLocale: NewsLocale.fromJson(json['NewsLocale']));
  }
  */

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
    if (maximumNewsCount == null) return 10;
    return this.maximumNewsCount;
  }
}

Setting setting = Setting();
/*
class Config {
  static LocalFiles _config = LocalFiles(dir: 'config.con');
  static Future<bool> initSetting() async {
    if (await _config.readcontent()) {
      print('Load Setting ${_config.content}');
      setting = Setting.fromJson(_config.content);
      setting.ratioDrawerMinHeight ??= setting.ratioDrawerMinHeightGet();
      setting.ratioDrawerMaxHeight ??= setting.ratioDrawerMaxHeightGet();
      setting.theme.darkMode ??= false;
      setting.maximumNewsCount ??= setting.maximumNewsCountGet();
      setting.autoPlay ??= setting.autoPlayGet();
      setting.autoPlayTime ??= setting.autoPlayTimeGet();
      setting.newsLocale.updates ??= true;
      setting.newsLocale.used ??= 0;
      print('Load Setting Return True');
      return true;
    } else {
      setting.theme = MyTheme();
      setting.newsLocale = NewsLocale();
      print('Load Setting Return False');
      return false;
    }
  }

  static Future<bool> saveSettings() async {
    _config.content =
        '{\"MyTheme\":{\"darkMode\":${setting.theme.darkMode.toString()}}, \"NewsLocale\":{\"updates\":${setting.newsLocale.updates.toString()},\"used\":${setting.newsLocale.used.toString()}}}';
    print(_config.content);
    return await _config.writeLocalFile();
  }
}
*/
