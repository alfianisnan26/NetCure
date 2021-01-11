import 'dart:ui';
import 'package:NetCure/database/hospital.dart';
import 'package:NetCure/dialogboxes.dart';
import 'package:NetCure/emergency/maps.dart' as maps;
import 'package:geolocator/geolocator.dart' show Position;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'newsapi.dart';
import 'database/setting.dart';
import 'dialogboxes.dart' as dialogBox;
import 'package:NetCure/database/db.dart' as db;
import 'package:NetCure/debug.dart' as debug;

BuildContext currentContext;
ValueNotifier<bool> updates = ValueNotifier(false);

class CardItem {
  Function onTap;
  Function onLongPress;
  var color;
  Widget smallWidget;
  Widget bigWidget;
  Widget expandedWidget;
  bool isExpanded = true;
  CardItem(this.onTap, this.color, this.smallWidget, this.bigWidget,
      this.expandedWidget,
      {this.onLongPress}) {
    if (this.expandedWidget == null)
      isExpanded = false;
    else
      isExpanded = true;
  }
}

class SmallCardExpanded extends StatefulWidget {
  final CardItem myCards;
  final int index;
  SmallCardExpanded({Key key, this.myCards, this.index}) : super(key: key);
  @override
  _SmallCardExpanded createState() => _SmallCardExpanded();
}

class _SmallCardExpanded extends State<SmallCardExpanded> {
  bool expanded = false, toExpand = false;
  final double expandedWidth = setting.screenSize.width;
  final double width =
      (setting.screenSize.height * setting.ratioDrawerMinHeightGet() - 40);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    updates.addListener(() {
      setState(() {
        print("Update_SmallCard");
      });
    });
    _scsv.addListener(() {
      if (_scsv.position.isScrollingNotifier.value && toExpand) {
        setState(() {
          expanded = false;
        });
        toExpand = false;
      }
    });
    super.initState();
  }

  void scrollAnimate() async {
    setState(() {
      expanded = true;
    });
    await Future.delayed(Duration(milliseconds: 125));
    print('${widget.index}');
    maps.maps.forLoc.value = widget.index;
    await _scsv.position.animateTo((widget.index * width),
        duration: Duration(milliseconds: 125), curve: Curves.fastOutSlowIn);
    print('Expanded = $expanded of ${widget.key.toString()}');
    print('_scsv ${_scsv.position.pixels}');

    setState(() {
      toExpand = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: widget.myCards.onLongPress,
        onTap: (!widget.myCards.isExpanded)
            ? widget.myCards.onTap
            : () {
                if (!expanded) {
                  scrollAnimate();
                } else {
                  widget.myCards.onTap();
                }
              },
        child: AnimatedContainer(
            padding: EdgeInsets.symmetric(vertical: 2),
            width: (expanded) ? expandedWidth : width,
            duration: Duration(milliseconds: 125),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              color: widget.myCards.color,
              child: (expanded && toExpand)
                  ? widget.myCards.expandedWidget
                  : widget.myCards.smallWidget,
            )));
  }
}

ScrollController _scsv = ScrollController();

class CardClass {
  List<Widget> cardBig, cardSmall;
  List<CardItem> myCards;
  bool canBig = false;
  CardClass(this.myCards, this.canBig, {String key = ""}) {
    if (myCards != null) renderCards(key);
  }

  void dumpGenerate(
      bool canBig, int length, Function func, var color, String key) {
    this.canBig = canBig;
    this.myCards = List.generate(length, (index) {
      return CardItem(
        func,
        color,
        Center(child: Text('${index + 1}', style: TextStyle(fontSize: 20))),
        Center(
          child: Text(
            '${index + 1}',
            style: TextStyle(fontSize: 30),
          ),
        ),
        Center(
            child:
                Text('This Is ${index + 1}', style: TextStyle(fontSize: 20))),
      );
    });
    renderCards(key);
  }

  void renderCards(String key) {
    cardSmall = List.generate(myCards.length, (index) {
      return new SmallCardExpanded(
        index: index,
        key: Key('$key SmallCard_$index'),
        myCards: myCards[index],
      );
    });
    if (!canBig) return;
    cardBig = List.generate(myCards.length, (index) {
      return Container(
          child: GestureDetector(
              onTap: myCards[index].onTap,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                color: myCards[index].color,
                child: myCards[index].bigWidget,
              )));
    });
  }

  Widget cardsGrid(bool isbig, Axis myAxis, int crossAxis, double size) {
    return Container(
      height: size,
      child: (!isbig)
          ? SingleChildScrollView(
              controller: _scsv,
              scrollDirection: myAxis,
              child: Row(
                children: cardSmall,
              ),
            )
          : GridView.count(
              scrollDirection: myAxis,
              padding: EdgeInsets.all(5),
              crossAxisCount: crossAxis,
              children: (isbig) ? cardBig : cardSmall),
    );
  }
}

class GenerateTabBar extends StatefulWidget {
  final bool state, mapState;
  final double ecp;
  final double stack;
  GenerateTabBar({Key key, this.stack, this.state, this.ecp, this.mapState})
      : super(key: key);
  _TabBar createState() => _TabBar();
}

class _TabBar extends State<GenerateTabBar>
    with SingleTickerProviderStateMixin {
  CardClass cardRoutines = CardClass(null, true),
      cardEmergency = CardClass(null, false),
      cardLogs = CardClass(null, true);

  TabController _controller;
  int currentClicked = 0;

  void emergencyGenerator() {
    cardEmergency.canBig = false;
    cardEmergency.myCards =
        List<CardItem>.generate(hospital.hospital.length, (index) {
      RSDBJB data = hospital.hospital[index];
      String estString;
      if (data.est.inMinutes < 1) {
        estString = "~" + data.est.inSeconds.toString() + " sec";
      } else if (data.est.inHours < 1) {
        estString = "~" +
            data.est.inMinutes.toString() +
            " min " +
            (data.est.inSeconds - (60 * data.est.inMinutes)).toString() +
            " sec";
      } else if (data.est.inDays < 1) {
        estString = "~" +
            data.est.inHours.toString() +
            " hrs " +
            (data.est.inMinutes - (60 * data.est.inHours)).toString() +
            " min";
      } else {
        estString = "~" +
            data.est.inDays.toString() +
            " day " +
            (data.est.inHours - (24 * data.est.inDays)).toString() +
            " hrs";
      }
      return CardItem(
          () => launch(
              "tel:${hospital.hospital[index].phone.replaceAll("-", "")}"),
          Colors.red,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                hospital.hospital[index].jenis +
                    " " +
                    hospital.hospital[index].nama,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                style: TextStyle(fontSize: setting.ratioDrawerMinHeight * 50),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  (hospital.hospital[index].radius != null)
                      ? (hospital.hospital[index].radius > 200)
                          ? ">200"
                          : hospital.hospital[index].radius.toStringAsFixed(1)
                      : "NaN",
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: setting.ratioDrawerMinHeight * 180),
                ),
                Text("km",
                    overflow: TextOverflow.fade,
                    style:
                        TextStyle(fontSize: setting.ratioDrawerMinHeight * 100))
              ]),
              Text(estString,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: setting.ratioDrawerMinHeight * 80)),
            ],
          ),
          null,
          SafeArea(
              minimum: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              top: true,
              bottom: true,
              left: true,
              right: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.phone,
                        style: TextStyle(fontSize: 17),
                        overflow: TextOverflow.visible,
                      ),
                      Text(data.radius.toStringAsFixed(1) + "km",
                          style: TextStyle(fontSize: 17),
                          overflow: TextOverflow.visible)
                    ],
                  ),
                  Text(
                    data.jenis + " " + data.nama,
                    overflow: TextOverflow.fade,
                    maxLines: 2,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: (setting.screenSize.height *
                            setting.ratioDrawerMinHeight *
                            0.15)),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(data.kecamatan, overflow: TextOverflow.ellipsis),
                      Text(estString, overflow: TextOverflow.ellipsis)
                    ],
                  )
                ],
              )));
    });
    cardEmergency.renderCards("Emergecy_Cards");
    updates.value = !updates.value;
  }

  void addNewRoutines() async {
    print("Get In Here");
    print("return" + (await routineAdd(context)).toString());
    db.profile.data.personal.routines.add(db.Routines(name: "Alfian"));
    print(
        "Add New Member Length : ${db.profile.data.personal.routines.length}");
    routinesGenerator();
  }

  void routinesGenerator() {
    cardRoutines.canBig = true;
    List<db.Routines> myRou = db.profile.data.personal.routines;
    int len = ((myRou.length == null) ? 0 : myRou.length) + 1;
    cardRoutines.myCards = List<CardItem>.generate(len, (a) {
      if (a == 0) {
        return CardItem(
            () => addNewRoutines(),
            Colors.green,
            SizedBox(
                height: setting.screenSize.height *
                    setting.ratioDrawerMinHeightGet(),
                child: Icon(Icons.add)),
            SizedBox(child: Icon(Icons.add)),
            null);
      } else
        return CardItem(
            () => ackAlert(context, "TestALertaa", "Number: $a"),
            Colors.green,
            SizedBox(
                height: setting.screenSize.height *
                    setting.ratioDrawerMinHeightGet(),
                child: Center(child: Text("TestSmall $a"))),
            Center(child: Text("TestBig $a")),
            SizedBox(
                height: setting.screenSize.height *
                    setting.ratioDrawerMinHeightGet(),
                child: Center(child: Text("TextExtended $a"))),
            onLongPress: () async {
          dialogToDelete(context, "TestDelete $a").then((value) {
            if (value) {
              db.profile.data.personal.routines.removeAt(a - 1);
              routinesGenerator();
            }
          });
        });
    });
    cardRoutines.renderCards("Routines_Cards");
    updates.value = !updates.value;
  }

  @override
  void initState() {
    super.initState();
    emergencyGenerator();
    routinesGenerator();
    updates.addListener(() {
      setState(() {
        print("Update_SmallCard");
      });
    });
    cardLogs.dumpGenerate(
        true,
        30,
        () => dialogBox.ackAlert(currentContext, 'Trial', 'Logs'),
        Colors.yellow,
        "Logs");
    _controller = TabController(length: 3, vsync: this);
    _controller.addListener(() {
      setState(() {
        print(_controller.index);
        _controller.animateTo(_controller.index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: DefaultTabController(
            length: 3, // length of tabs
            initialIndex: 0,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    color:
                        setting.theme.darkMode ? Colors.black87 : Colors.white,
                    height: 40,
                    child: TabBar(
                      controller: _controller,
                      labelStyle: GoogleFonts.montserrat(
                          fontSize: 10, fontWeight: FontWeight.bold),
                      labelColor: Colors.green,
                      unselectedLabelColor:
                          setting.theme.darkMode ? Colors.white : Colors.black,
                      tabs: [
                        Tab(text: 'MY ROUTINES'),
                        Tab(text: 'EMERGENCY'),
                        Tab(text: 'CURELOGS'),
                      ],
                    ),
                  ),
                  Container(
                      height: (setting.screenSize.height) *
                              setting.ratioDrawerMaxHeightGet() -
                          40, //height of TabBarView
                      decoration: BoxDecoration(
                          color: setting.theme.darkMode
                              ? Colors.black87
                              : Colors.white,
                          border: Border(
                              top: BorderSide(color: Colors.grey, width: 0.5))),
                      child: TabBarView(controller: _controller, children: <
                          Widget>[
                        Opacity(
                            opacity: widget.stack,
                            child: Stack(children: [
                              cardRoutines.cardsGrid(
                                  widget.state,
                                  (widget.state)
                                      ? Axis.vertical
                                      : Axis.horizontal,
                                  (widget.state) ? setting.drawerRowGet() : 1,
                                  (widget.state)
                                      ? null
                                      : (setting.screenSize.height *
                                              setting
                                                  .ratioDrawerMinHeightGet() -
                                          40))
                            ])),
                        Container(
                            child: Stack(
                          children: [
                            Container(
                              height: (setting.screenSize.height *
                                          setting.ratioDrawerMaxHeightGet() -
                                      40) -
                                  (setting.screenSize.height *
                                          setting.ratioDrawerMinHeightGet() -
                                      40) -
                                  0.5,
                              child: FutureBuilder(
                                future: maps.maps.updatePos(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<Position> ss) {
                                  if (ss.hasData) {
                                    return maps.SmallMaps();
                                  } else if (ss.hasError) {
                                    return Center(
                                        child: Text("Sorry, cannot load maps"));
                                  } else {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: widget.ecp),
                                child: Stack(children: [
                                  Container(
                                    height: setting.screenSize.height *
                                            setting.ratioDrawerMinHeightGet() -
                                        40,
                                    width: setting.screenSize.width,
                                    color: (setting.theme.darkMode)
                                        ? Colors.grey.shade900
                                        : Colors.white,
                                  ),
                                  Container(
                                      height: setting.screenSize.height *
                                              setting
                                                  .ratioDrawerMinHeightGet() -
                                          40,
                                      color: (setting.theme.darkMode)
                                          ? Colors.grey.shade900
                                          : Colors.white,
                                      child: cardEmergency.cardsGrid(
                                        false,
                                        Axis.horizontal,
                                        1,
                                        null,
                                      ))
                                ])),
                          ],
                        )),
                        Opacity(
                            opacity: widget.stack,
                            child: Stack(children: [
                              cardLogs.cardsGrid(
                                  widget.state,
                                  (widget.state)
                                      ? Axis.vertical
                                      : Axis.horizontal,
                                  (widget.state) ? setting.drawerRowGet() : 1,
                                  (widget.state)
                                      ? null
                                      : (setting.screenSize.height *
                                              setting
                                                  .ratioDrawerMinHeightGet() -
                                          40))
                            ])),
                      ]))
                ])));
  }
}

class SlideBar {
  Widget value, blurr;
  SlideBar() {
    this.close();
  }

  Widget _blurLayer(bool blurVisible, double blurVal) {
    return Visibility(
        key: Key('BlurLayer'),
        visible: blurVisible,
        child: Container(
            height: setting.screenSize.height,
            width: setting.screenSize.width,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurVal, sigmaY: blurVal),
              child: Container(
                color: Colors.black.withOpacity(0),
              ),
            )));
  }

  bool curState = false;
  double curVal;

  void close() {
    curState = false;
    this.blurr = _blurLayer(false, 0);
    this.value = GenerateTabBar(
      stack: 1,
      state: false,
      ecp: 0,
      mapState: curState,
    );
  }

  void open() {
    curState = true;
    this.value = GenerateTabBar(
      stack: 1,
      state: true,
      ecp: curVal,
      mapState: curState,
    );
  }

  void set(double val) {
    bool state;
    this.blurr = _blurLayer(true, val * 5);
    curVal = val *
        ((setting.screenSize.height * setting.ratioDrawerMaxHeightGet()) -
            (setting.screenSize.height * setting.ratioDrawerMinHeightGet()));
    if (val >= 0.5) {
      val = (val - 0.5) * 2;
      state = true;
    } else if (val < 0.5) {
      val = 1 - val * 2;
      state = false;
    }
    this.value = GenerateTabBar(
        mapState: curState, state: state, stack: val, ecp: curVal);
  }
}

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Padding(
                padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
                child: Text(db.profile.data.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900))),
            decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: (db.profile.data.personal.myPhoto == null)
                        ? AssetImage("assets/images/pillsBW.jpg")
                        : MemoryImage(db.profile.data.personal.myPhoto))),
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title:
                Text('PROFILE', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => {
              Navigator.of(context).pop(),
              Navigator.pushNamed(context, '/Dashboard/Profile')
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title:
                Text('SETTING', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => {
              Navigator.of(context).pop(),
              Navigator.pushNamed(context, '/Dashboard/Settings')
            },
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title:
                Text('FEEDBACK', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
              leading: Icon(Icons.help),
              title:
                  Text('HELP', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => debug.onlyForDebug(context)
              //Navigator.of(context).pop()
              ),
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title:
                  Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                setting.thisTrue = false;
                if (await setting.deleteSession())
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', ModalRoute.withName('/'));
              }),
        ],
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _Dashboard createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  SlideBar slideBar = SlideBar();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
    _controller.addListener(() {
      setState(() {});
    });
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    return Scaffold(
        drawer: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5.0,
              sigmaY: 5.0,
            ),
            child: NavDrawer()),
        body: SafeArea(
            child: SlidingUpPanel(
                // isDraggable: false,
                minHeight: (setting.screenSize.height *
                    setting.ratioDrawerMinHeightGet()),
                maxHeight: (setting.screenSize.height *
                    setting.ratioDrawerMaxHeightGet()),
                onPanelSlide: (val) {
                  setState(() {
                    slideBar.set(val);
                  });
                },
                onPanelClosed: () {
                  slideBar.close();
                },
                onPanelOpened: () {
                  slideBar.open();
                },
                parallaxEnabled: true,
                backdropEnabled: true,
                panel: slideBar.value,
                body: Stack(children: [
                  Container(
                      height: setting.screenSize.height,
                      width: setting.screenSize.width,
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.all(10),
                      child: Stack(
                        children: [
                          Container(
                              padding: EdgeInsets.fromLTRB(150, 0, 0, 0),
                              child: Image.asset(
                                "assets/images/pills.png",
                              )),
                          Container(
                              padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                              child: Image.asset(
                                "assets/images/banner.png",
                                height: 70,
                              ))
                        ],
                      )),
                  NewsCards(),
                  slideBar.blurr
                ]))));
  }
}
