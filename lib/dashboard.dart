import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:re_netcure/hospitalmap.dart' as maps;
import 'newsapi.dart';
import 'setting.dart';
<<<<<<< HEAD
import 'dialogboxes.dart';
=======
import 'dialogboxes.dart' as dialogBox;
>>>>>>> 5df89dafb086f713aca5eff97fada6f12d9dfabe

BuildContext currentContext;

class CardItem {
  Function onTap;
  var color;
  Widget smallWidget;
  Widget bigWidget;
  CardItem(this.onTap, this.color, this.smallWidget, this.bigWidget);
}

<<<<<<< HEAD
  List<Widget> generatedRoutines, generatedEmergency;

  List<Widget> generateCards() {
    return List.generate(50, (index) {
      if (index == 0) {
        return Hero(
            tag: 'ROUTINE_$index',
            child: Container(
                child: GestureDetector(
                    onTap: () => ackAlert(currentContext, "Add Routines",
                        "Feature is Under Develope"),
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        color: Colors.green,
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 30,
                        )))));
      }
      return Hero(
          tag: 'ROUTINE_$index',
          child: Container(
              child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            color: Colors.amber,
=======
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
>>>>>>> 5df89dafb086f713aca5eff97fada6f12d9dfabe
          )));
    });
    renderCards();
  }

<<<<<<< HEAD
  Widget _cards(Axis myAxis, int crossAxis, double size, List<Widget> cards) {
=======
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
>>>>>>> 5df89dafb086f713aca5eff97fada6f12d9dfabe
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

class SlideBar {
  Widget value, blurr;

  CardClass cardRoutines = CardClass(null, true),
      cardEmergency = CardClass(null, false);

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

  Widget _family(bool state, double stack) {
    return Stack(
        children: <Widget> [DefaultTabController(
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
                      child: TabBarView(children: <Widget>[
                        Opacity(
                            opacity: stack,
                            child: Stack(children: [
<<<<<<< HEAD
                              _cards(
=======
                              cardRoutines.cardsGrid(
                                  state,
>>>>>>> 5df89dafb086f713aca5eff97fada6f12d9dfabe
                                  (state) ? Axis.vertical : Axis.horizontal,
                                  (state) ? setting.drawerRowGet() : 1,
                                  (state)
                                      ? null
                                      : (setting.screenSize.height *
                                              setting
                                                  .ratioDrawerMinHeightGet() -
<<<<<<< HEAD
                                          40),
                                  generatedRoutines)
                            ])),
                        Container(
                          child: Center(
                            child: Column(
                              children: [
                                _cards(
                                    Axis.horizontal,
                                    1,
                                    (setting.screenSize.height *
                                            setting.ratioDrawerMinHeightGet() -
                                        40),
                                    generatedEmergency),
                                Container(
                                 // color: Colors.red,
                                  height: 370,
                                  width: setting.screenSize.width,
                                  child: MapNew(),
                                )
                              ],
                            ),
                          ),
                        ),
=======
                                          40))
                            ])),
                        Container(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            cardEmergency.cardsGrid(
                              false,
                              Axis.horizontal,
                              1,
                              setting.screenSize.height *
                                      setting.ratioDrawerMinHeightGet() -
                                  40,
                            ),
                            Container(
                                height: (setting.screenSize.height *
                                            setting.ratioDrawerMaxHeightGet() -
                                        40) -
                                    (setting.screenSize.height *
                                            setting.ratioDrawerMinHeightGet() -
                                        40) -
                                    0.5,
                                child: maps.MapNew()),
                          ],
                        )),
>>>>>>> 5df89dafb086f713aca5eff97fada6f12d9dfabe
                        Container(
                          child: Center(
                            child: Text('Display Tab 3',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ]))
                ]))]);
  }

  SlideBar() {
<<<<<<< HEAD
    generatedRoutines = generateCards();
    generatedEmergency = generateCards();
=======
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
>>>>>>> 5df89dafb086f713aca5eff97fada6f12d9dfabe
    this.close();
  }

  void close() {
    this.blurr = _blurLayer(false, 0);
    this.value = _family(false, 1);
  }

  void set(double val) {
    bool state;
    this.blurr = _blurLayer(true, val * 5);
    if (val >= 0.5) {
      val = (val - 0.5) * 2;
      state = true;
    } else if (val < 0.5) {
      val = 1 - val * 2;
      state = false;
    }
    this.value = _family(state, val);
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
                  setState(() {
                    slideBar.close();
                  });
                },
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