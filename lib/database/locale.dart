import 'package:flutter/material.dart';

class NewsLocale {
  NewsLocale({this.updates = true, this.used = 0});
  factory NewsLocale.fromJson(dynamic json) {
    return NewsLocale(
        updates: json['updates'] as bool, used: json['used'] as int);
  }
  Map<String, dynamic> toJson() =>
      {"\"updates\"": this.updates, "\"used\"": this.used};

  bool updates = false;
  String _links = "https://newsapi.org/v2/top-headlines";
  String _apikey = "ef725f20d8e14cb08e487f74ac7cfc13";
  List<String> id = [
    'ww',
    'ae',
    'ar',
    'at',
    'au',
    'be',
    'bg',
    'ca',
    'ch',
    'cn',
    'co',
    'cu',
    'cz',
    'de',
    'eg',
    'fr',
    'gb',
    'gr',
    'hk',
    'hu',
    'id',
    'ie',
    'il',
    'in',
    'it',
    'jp',
    'kr',
    'lt',
    'lv',
    'ma',
    'mx',
    'my',
    'ng',
    'nl',
    'no',
    'nz',
    'ph',
    'pl',
    'pt',
    'ro',
    'rs',
    'ru',
    'sa',
    'se',
    'sg',
    'si',
    'sk',
    'th',
    'tr',
    'tw',
    'ua',
    'us',
    've',
    'za'
  ];
  final List<String> str = [
    'Worldwide',
    'Uni Arab Emirates',
    'Argentina',
    'Austria',
    'Australia',
    'Belgium',
    'Bulgaria',
    'Canada',
    'Switzerland',
    'China',
    'Colombia',
    'Cuba',
    'Czech Republic',
    'Germany',
    'Egypt',
    'France',
    'United Kingdom',
    'Greece',
    'Hong Kong',
    'Hungary',
    'Indonesia',
    'Ireland',
    'Israel',
    'India',
    'Italy',
    'Japan',
    'Korea',
    'Latvia',
    'Morocco',
    'Mexico',
    'Malaysia',
    'Nigeria',
    'Netherlands',
    'Norway',
    'New Zealand',
    'Philippines',
    'Poland',
    'Portugal',
    'Romania',
    'Serbia',
    'Rusia',
    'Saudi Arabia',
    'Sweden',
    'Singapore',
    'Slovenia',
    'Slovakia',
    'Thailand',
    'Turkey',
    'Taiwan',
    'Ukraine',
    'United States',
    'Venezuela',
    'South Africa'
  ];
  int used = 0;
  String get usedID {
    return this.id[used];
  }

  String get link {
    print("USED : ${this.used}");
    if (this.used == 0)
      return "${this._links}?category=health&apiKey=${this._apikey}";
    else
      return "${this._links}?country=${this.usedID}&category=health&apiKey=${this._apikey}";
  }

  List<DropdownMenuItem<String>> generateList() {
    List<DropdownMenuItem<String>> myVal = [];
    for (int a = 0; a < str.length; a++) {
      myVal.add(DropdownMenuItem(
        child: Text(
          str[a],
          style: TextStyle(fontSize: 15),
        ),
        value: str[a],
      ));
    }
    return myVal;
  }
}
