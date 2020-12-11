import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:re_netcure/hospital/hospitallist.dart';
import 'newsapi.dart';
import 'setting.dart';
import 'dialogboxes.dart';

BuildContext currentContext;

class SlideBar {
  Widget value, blurr;

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
          )));
    });
  }

  Widget _cards(Axis myAxis, int crossAxis, double size, List<Widget> cards) {
    return Container(
      height: size,
      child: GridView.count(
          scrollDirection: myAxis,
          padding: EdgeInsets.all(5),
          crossAxisCount: crossAxis,
          children: generatedRoutines),
    );
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

  Widget _family(bool state, double stack) {
    return Stack(children: <Widget>[
      DefaultTabController(
          length: 3, // length of tabs
          initialIndex: 0,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  color: setting.theme.darkMode ? Colors.black87 : Colors.white,
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
                            _cards(
                                (state) ? Axis.vertical : Axis.horizontal,
                                (state) ? setting.drawerRowGet() : 1,
                                (state)
                                    ? null
                                    : (setting.screenSize.height *
                                            setting.ratioDrawerMinHeightGet() -
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
                                height: 450,
                                width: setting.screenSize.width,
                                child: HospitalList(),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: Center(
                          child: Text('Display Tab 3',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]))
              ]))
    ]);
  }

  SlideBar() {
    generatedRoutines = generateCards();
    generatedEmergency = generateCards();
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
