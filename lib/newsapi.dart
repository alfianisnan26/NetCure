import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:re_netcure/dialogboxes.dart';
import 'setting.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class Source {
  String id;
  String name;

  Source(this.id, this.name);

  factory Source.fromJson(dynamic json) {
    return Source(json['id'] as String, json['name'] as String);
  }
}

class Articles {
  Source source;
  int index;
  String author, title, description, url, urlToImage, publishedAt, content;
  CachedNetworkImageProvider image;
  Articles(this.source, this.author, this.title, this.description, this.url,
      this.urlToImage, this.publishedAt, this.content);
  factory Articles.fromJson(dynamic json) {
    return Articles(
        Source.fromJson(json['source']),
        json['author'] as String,
        json['title'] as String,
        json['description'] as String,
        json['url'] as String,
        json['urlToImage'] as String,
        json['publishedAt'] as String,
        json['content'] as String);
  }

  @override
  String toString() {
    return '{ ${this.source}, ${this.author}, ${this.title}, ${this.description}, ${this.url}, ${this.urlToImage}, ${this.publishedAt}, ${this.content}';
  }
}

class NewsGet {
  bool status;
  int totalResults;
  List<Articles> articles;

  NewsGet(this.status, this.totalResults, [this.articles]);

  factory NewsGet.fromJson(dynamic json) {
    bool mystats;
    if (json['status'] == 'ok')
      mystats = true;
    else
      mystats = false;
    if (json['articles'] != null) {
      var tagObjsJson = json['articles'] as List;
      List<Articles> _tags =
          tagObjsJson.map((tagJson) => Articles.fromJson(tagJson)).toList();

      return NewsGet(mystats, json['totalResults'] as int, _tags);
    } else {
      return NewsGet(mystats, json['totalResults'] as int);
    }
  }
}

// ignore: must_be_immutable
class Item extends StatefulWidget {
  final Articles resp;
  bool state;
  Item({Key key, @required this.state, this.resp}) : super(key: key);

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  Widget myChild;

  @override
  Widget build(BuildContext context) {
    if (widget.state && widget.resp != null) {
      myChild = GestureDetector(
          onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WebViewScreen(resp: widget.resp)),
              ),
          child: Hero(
            tag: "NEWS_CARD_${widget.resp.index}",
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black,
                    image: DecorationImage(
                        image: widget.resp.image,
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.75),
                            BlendMode.dstATop))),
                child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("${widget.resp.title}",
                              maxLines: 4,c
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              "${(widget.resp.author != null) ? widget.resp.author.toUpperCase() : ""}",
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w300)),
                        ]))),
          ));
    } else if (widget.state && widget.resp == null) {
      myChild = Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: Colors.red),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Error",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold)),
              Text("Cannot Retrive Data",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600)),
            ],
          ));
    } else if (!widget.state) {
      myChild = Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: Colors.grey),
          child: SpinKitPumpingHeart(
            color: Colors.white,
            size: 50.0,
          ));
    }
    return myChild;
  }
}

class NewsCards extends StatefulWidget {
  NewsCards({Key key}) : super(key: key);
  @override
  _NewsCards createState() => _NewsCards();
}

class _NewsCards extends State<NewsCards> {
  int _currentIndex = 0;
  List cardList = [];
  bool hasDataApi = false;
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  Future<NewsGet> loadNews() async {
    final http.Response resp = await http.get(
        "https://newsapi.org/v2/top-headlines?country=${setting.valNewsLocale()}&category=health&apiKey=9c61a9a50a194efdadb202fb91cbc490");
    NewsGet foo = NewsGet.fromJson(jsonDecode(resp.body));
    for (int a = 0; a <= setting.maximumNewsCount();) {
      final http.Response resp = await http.get(foo.articles[a].urlToImage);
      if (resp.statusCode == 200) {
        foo.articles[a].image =
            CachedNetworkImageProvider(foo.articles[a].urlToImage);
        if (foo.articles[a].image != null) {
          foo.articles[a].index = a;
          cardList.add(
              Item(key: Key("ITEM_$a"), state: true, resp: foo.articles[a]));
          a++;
        } else
          foo.articles.removeAt(a);
      } else
        foo.articles.removeAt(a);
    }
    foo.articles.removeRange(setting.maximumNewsCount(), foo.articles.length);
    return foo;
  }

  Widget cardsWidget() {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          CarouselSlider(
            height: 200.0,
            autoPlay: setting.autoPlay(),
            autoPlayInterval: setting.autoPlayTime(),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            pauseAutoPlayOnTouch: Duration(seconds: 10),
            aspectRatio: 2.0,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: cardList.map((card) {
              return Builder(builder: (BuildContext context) {
                return Container(
                  padding: EdgeInsets.all(5),
                  height: MediaQuery.of(context).size.height * 0.30,
                  width: MediaQuery.of(context).size.width,
                  child: card,
                );
              });
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: map<Widget>(cardList, (index, url) {
              return Container(
                width: 10.0,
                height: 10.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentIndex == index ? Colors.purple[200] : Colors.grey,
                ),
              );
            }),
          )
        ]));
  }

  Future<NewsGet> newsList;

  @override
  void initState() {
    newsList = loadNews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NewsGet>(
        future: newsList,
        builder: (BuildContext context, ss) {
          if (ss.connectionState == ConnectionState.done && ss.hasData) {
            if (!hasDataApi) {
              hasDataApi = true;
            }
            return cardsWidget();
          }
          return Center(
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                CarouselSlider(
                    enableInfiniteScroll: false,
                    height: 200.0,
                    aspectRatio: 2.0,
                    items: <Widget>[
                      Container(
                        padding: EdgeInsets.all(5),
                        height: MediaQuery.of(context).size.height * 0.30,
                        width: MediaQuery.of(context).size.width,
                        child: Item(
                          state: (ss.hasError) ? true : false,
                        ),
                      )
                    ]),
                Container(
                    width: 10.0,
                    height: 10.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ))
              ])));
        });
  }
}
