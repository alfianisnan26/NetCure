class Setting {
  int intMaximumNewsCount;
  bool boolAutoPlay;
  Duration durationAutoPlayTime;
  String newsLocale;
  String valNewsLocale() {
    if (newsLocale == null) return "us";
    return this.newsLocale;
  }

  bool autoPlay() {
    if (boolAutoPlay == null) return true;
    return this.boolAutoPlay;
  }

  Duration autoPlayTime() {
    if (durationAutoPlayTime == null) return Duration(seconds: 5);
    return this.durationAutoPlayTime;
  }

  int maximumNewsCount() {
    if (intMaximumNewsCount == null) return 5;
    return this.intMaximumNewsCount;
  }
}

Setting setting = Setting();
