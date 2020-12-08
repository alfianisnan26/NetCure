import 'dart:ui';

class Setting {
  Size screenSize;
  int maximumNewsCount;
  int drawerRow;
  bool autoPlay;
  Duration autoPlayTime;
  String newsLocale;
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

  String newsLocaleGet() {
    if (newsLocale == null) return "us";
    return this.newsLocale;
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
}

Setting setting = Setting();
