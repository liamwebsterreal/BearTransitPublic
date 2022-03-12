
import 'package:bear_transit_app/models/global.dart';
import 'package:bear_transit_app/screens/bearADs.dart';
import 'package:bear_transit_app/screens/bearmap.dart';
import 'package:bear_transit_app/screens/bearnews.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  void init(BuildContext context){
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth/100;
    blockSizeVertical = screenHeight/100;
    _safeAreaHorizontal = _mediaQueryData.padding.left +
        _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top +
        _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal)/100;
    safeBlockVertical = (screenHeight - _safeAreaVertical)/100;
  }
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bear Transit',
      home: FutureBuilder(
        future: _fbApp,
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            print("you have an Error! ${snapshot.error.toString()}");
                return Text('Something went wrong');
          }else if(snapshot.hasData) {
            return MyHomePage();
          } else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _currentIndex = 1;

  PageController? _pageController;

  @override
  void initState(){
    super.initState();
    _pageController =  new PageController(
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  List<Widget> tabPages = [
    bearnews(),
    bearmap(),
    bearADs(),
  ];

  final _bottomNavigationBarItems = [
    BottomNavigationBarItem(
        icon: Icon(Icons.circle),
        title: Text('BearNews', style: techCardBodyStyle)),
    BottomNavigationBarItem(
        icon: Icon(Icons.circle),
        title: Text('BearMap', style: techCardBodyStyle)),
    BottomNavigationBarItem(
        icon: Icon(Icons.circle),
        title: Text('BearDeals', style: techCardBodyStyle)),
  ];

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

        bottomNavigationBar: Padding(
          padding: EdgeInsets.only( bottom: SizeConfig.safeBlockVertical * 1, left: SizeConfig.safeBlockHorizontal * 3, right: SizeConfig.safeBlockHorizontal * 3),

          child:
            SizedBox(
              height: SizeConfig.safeBlockVertical * 9,
              child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                    topRight: Radius.circular(100),
                    topLeft: Radius.circular(100),
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black38, spreadRadius: 0, blurRadius: 10),
                    ],
                  ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100.0),
                  topRight: Radius.circular(100.0),
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100)),
                  child : BottomNavigationBar(
                    iconSize: 2,
                    currentIndex: _currentIndex,
                    items: _bottomNavigationBarItems,
                    showUnselectedLabels: false,
                    showSelectedLabels: false,
                    selectedItemColor: Color(0xff003262),
                    unselectedItemColor: Colors.grey,
                    onTap: (index) {
                      _pageController!.animateToPage(index, duration: Duration(microseconds: 500), curve: Curves.ease);
                      setState(() {
                        _currentIndex = index;
                    });
                  },
                ),
              ),
              ),
        ),
        ),
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
