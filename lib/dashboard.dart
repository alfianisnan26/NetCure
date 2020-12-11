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
  CardItem(this.onTap, this.color, this.smallWidget, this.bigWidget);
}

class CardClass {
  List<Widget> cardBig, cardSmall;
  List<CardItem> myCards;
  bool canBig = false;
  CardClass(this.myCards, this.canBig) {
    if (myCards != null) renderCards();
  }

  void dumpGenerate(bool canBig, int length, Function func, var color) {
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
          )));
    });
    renderCards();
  }

  void renderCards() {
    cardSmall = List.generate(myCards.length, (index) {
      return Container(
          child: GestureDetector(
              onTap: myCards[index].onTap,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                color: myCards[index].color,
                child: myCards[index].smallWidget,
              )));
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
      child: GridView.count(
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

  @override
  void initState() {
    super.initState();
    cardRoutines.dumpGenerate(
        true,
        25,
        () => dialogBox.ackAlert(currentContext, 'Trial', 'Routines'),
        Colors.green);
    cardEmergency.dumpGenerate(
        false,
        10,
        () => dialogBox.ackAlert(currentContext, 'Trial', 'Emergency'),
        Colors.red);
    cardLogs.dumpGenerate(
        true,
        30,
        () => dialogBox.ackAlert(currentContext, 'Trial', 'Logs'),
        Colors.yellow);
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
