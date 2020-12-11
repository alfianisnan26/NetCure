import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:re_netcure/hospitalmap.dart' as maps;
//import 'maps.dart' as maps;
import 'newsapi.dart';
import 'setting.dart';
import 'dialogboxes.dart' as dialogBox;

BuildContext currentContext;

class CardItem {
  Function onTap;
  var color;
  Widget smallWidget;
  Widget bigWidget;
  Widget expandedWidget;
  CardItem(this.onTap, this.color, this.smallWidget, this.bigWidget,
      this.expandedWidget);
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
    await _scsv.position.animateTo((widget.index * width),
        duration: Duration(milliseconds: 125), curve: Curves.fastOutSlowIn);
    print('Expanded = $expanded of ${widget.key.toString()}');
    print('_scsv ${_scsv.position.pixels}');
    toExpand = true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
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
              child: widget.myCards.smallWidget,
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

  @override
  void initState() {
    super.initState();
    cardRoutines.dumpGenerate(
        true,
        25,
        () => dialogBox.ackAlert(currentContext, 'Trial', 'Routines'),
        Colors.green,
        "Routine");
    cardEmergency.dumpGenerate(
        false,
        10,
        () => dialogBox.ackAlert(currentContext, 'Trial', 'Emergency'),
        Colors.red,
        "Emergency");
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
                                color: Colors.red,
                                height: (setting.screenSize.height *
                                            setting.ratioDrawerMaxHeightGet() -
                                        40) -
                                    (setting.screenSize.height *
                                            setting.ratioDrawerMinHeightGet() -
                                        40) -
                                    0.5,
                                child:
                                    (widget.mapState) ? maps.MapNew() : null),
                            Padding(
                                padding: EdgeInsets.only(top: widget.ecp),
                                child: Container(
                                    height: setting.screenSize.height *
                                            setting.ratioDrawerMinHeightGet() -
                                        40,
                                    color: (setting.theme.darkMode)
                                        ? Colors.grey.shade900
                                        : Colors.white,
                                    child: cardEmergency.cardsGrid(
                                      false,
                                      Axis.horizontal,
                                      1,
                                      null,
                                    ))),
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
                child: Text('Who Am I',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900))),
            decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        'https://cdn.mos.cms.futurecdn.net/YLMh9EJRPhmht9GWNhiN7G-970-80.jpg.webp'))),
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title:
                Text('PROFILE', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => {Navigator.of(context).pop()},
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
              leading: Icon(Icons.exit_to_app),
              title:
                  Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/', ModalRoute.withName('/'))),
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
    _controller.dispose();
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
                  print('isClosed');
                },
                onPanelOpened: () {
                  slideBar.open();
                  print('isOpen');
                },
                parallaxEnabled: true,
                backdropEnabled: true,
                panel: slideBar.value,
                body: Stack(children: [
                  Hero(
                    tag: 'banner',
                    child: Container(
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
                  ),
                  NewsCards(),
                  slideBar.blurr
                ]))));
  }
}
