import 'dart:math';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:NetCure/dialogboxes.dart';
import 'database/setting.dart';

class Source {
  String id;
  String name;

  Source(this.id, this.name);
  String stringify() {
    return "{\"id\":\"$id\"" + "\"name\":\"$name\"}";
  }

  factory Source.fromJson(dynamic json) {
    return Source(json['id'] as String, json['name'] as String);
  }
}

class Articles {
  Source source;
  bool state = false;
  String author, title, description, url, urlToImage, publishedAt, content;
  Articles(this.source, this.author, this.title, this.description, this.url,
      this.urlToImage, this.publishedAt, this.content);
  String stringify() {
    return "{\"source\":${source.stringify()}," +
        "\"author\":\"$author\"," +
        "\"author\":\"$title\"," +
        "\"author\":\"$description\"," +
        "\"author\":\"$url\"," +
        "\"author\":\"$urlToImage\"," +
        "\"author\":\"$publishedAt\"," +
        "\"author\":\"$content\"}";
  }

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
}

class NewsGet {
  bool status;
  int realTotal = 0;
  List<Articles> articles;

  NewsGet(this.status, [this.articles]);

  String stringify() {
    String article = "";
    for (int a = 0; a < articles.length; a++) {
      article += articles[a].stringify();
    }
    return "{\"status\":\"${this.status}\",\"articles\":[$article]";
  }

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

      return NewsGet(mystats, _tags);
    } else {
      return NewsGet(mystats);
    }
  }
}

// ignore: must_be_immutable
class Item extends StatefulWidget {
  final Articles resp;
  bool state = false;
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
        child: Stack(alignment: Alignment.center, children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    image: DecorationImage(
                        image: AssetImage('assets/images/pillsBW.jpg'),
                        fit: BoxFit.cover),
                  ),
                  child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5), BlendMode.darken),
                      child: FadeInImage.memoryNetwork(
                          height: 200,
                          width: 200 / 9 * 16,
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                          placeholder: kTransparentImage,
                          image: widget.resp.urlToImage)))),
          Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("${widget.resp.title}",
                        maxLines: 4,
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
                  ]))
        ]),
      );
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

  NewsGet checkNews(NewsGet a) {
    print('Total Articles ${a.articles.length}');
    a.articles.removeWhere((element) => (element.content == null));
    print('Total Articles Registered ${a.articles.length}');
    return a;
  }

  NewsGet generateNews(NewsGet foo) {
    NewsGet forReturn = NewsGet(true, []);
    for (int a = 0; a < foo.articles.length; a++) {
      print('Article Load at $a');
      if (cardList.length >= setting.maximumNewsCountGet()) {
        print('Maximum News Count Triggered');
        break;
      }
      int b;
      do {
        b = Random().nextInt(foo.articles.length);
        print('Article rand at $b state: ${foo.articles[b].state}');
      } while (foo.articles[b].state);
      foo.articles[b].state = true;
      print('Add Articles Index $a of ${cardList.length} available at $b');
      forReturn.articles.add(foo.articles[b]);
      cardList
          .add(Item(key: Key("ITEM_$a"), state: true, resp: foo.articles[b]));
      print('Add new Cards');
    }
    return forReturn;
  }

  Future<NewsGet> loadNews() async {
    NewsGet foo, forReturn = NewsGet(false, []);
    final http.Response resp = await http.get(setting.newsLocale.link);
    if (resp.statusCode != 200) {
      print(
          'Getting Data ONLINE FAILED error ${resp.statusCode} from ${setting.newsLocale.link}');
      return NewsGet(false, null);
    }
    foo = checkNews(NewsGet.fromJson(jsonDecode(resp.body)));
    print('Getting Data ONLINE SUCCESS from ${setting.newsLocale.link}');
    forReturn = generateNews(foo);
    if (forReturn.realTotal == 0) {
      return NewsGet(false);
    } else {
      return forReturn;
    }
  }

  Widget cardsWidget() {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          CarouselSlider(
            height: 200.0,
            autoPlay: setting.autoPlayGet(),
            autoPlayInterval: Duration(seconds: setting.autoPlayTimeGet()),
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
                  color: _currentIndex == index
                      ? Colors.deepPurple[800]
                      : Colors.grey,
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
            if (!hasDataApi && ss.data.status && ss.hasData) {
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
