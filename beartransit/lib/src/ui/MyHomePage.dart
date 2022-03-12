
import 'package:beartransit/src/resources/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';


import '../app.dart';
import 'bearmap.dart';
import 'bearnews.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title}) : super();

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _currentIndex = 1;
  PageController? _pageController;


  List<Widget> tabPages = [
    bearnews(),
    bearmap(),
  ];

  final _bottomNavigationBarItems = [
    BottomNavyBarItem(
      icon: Icon(Icons.circle),
      title: Text(''),
      activeColor: Color(0xff003262),
      inactiveColor: Colors.grey
  ),
    BottomNavyBarItem(
      icon: Icon(Icons.circle),
      title: Text(''),
        activeColor: Color(0xff003262),
        inactiveColor: Colors.grey
    )
  ];

  @override
  void initState() {
    super.initState();
    _pageController =  new PageController(
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: PageView(
        children: tabPages,
        onPageChanged: onPageChanged,
        controller: _pageController,
      ),
      bottomNavigationBar:
        Container(
          alignment: Alignment.bottomCenter,
          child: BottomNavyBar(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            selectedIndex: _currentIndex,
            items: _bottomNavigationBarItems,
            onItemSelected: (index) {
              _pageController!.animateToPage(index, duration: Duration(microseconds: 500), curve: Curves.ease);
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        )
    );
  }
  void onPageChanged(int page) {
    setState(() {
      this._currentIndex = page;
    });
  }

  void onTabTapped(int index) {
    this._pageController!.animateToPage(index,duration: const Duration(milliseconds: 500),curve: Curves.easeIn);
  }
}
