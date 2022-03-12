import 'dart:async';
import 'dart:collection';
import 'dart:core';
import 'dart:ui';

import 'package:bear_transit_app/models/coordList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException, rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../main.dart';
import 'package:bear_transit_app/models/global.dart';
import 'package:bear_transit_app/models/bus.dart';
import 'package:bear_transit_app/models/ucpdMarker.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';




class bearmap extends StatefulWidget {
  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<bearmap> {
  Completer<GoogleMapController> _controller = Completer();

  //GoogleMapController _controller;
  String? _mapStyle;
  List<Bus>? buses;
  Set<Polyline> _polylines = {};
  Set<Marker> busStopmarkers = {};
  Set<Marker> busMarkers = {};
  Set<Marker> _finalmarkers = {};
  late BitmapDescriptor pinLocationIcon;
  late BitmapDescriptor pinUCPDIcon;
  late BitmapDescriptor clineIcon;
  late BitmapDescriptor hlineIcon;
  late BitmapDescriptor plineIcon;
  late BitmapDescriptor rlineIcon;
  late List<String> ucpdmarkers;

  final database = FirebaseDatabase.instance.reference();
  Map<String, dynamic> data = {};
  Queue<ucpdMarker> ucpdmarkerobjList = Queue();

  List<LatLng> polypointsH = [];
  List<LatLng> polypointsC = [];
  List<LatLng> polypointsP = [];
  List<LatLng> polypointsR = [];

  Set<String> clineBuses = {};
  Set<String> hlineBuses = {};
  Set<String> plineBuses = {};
  Set<String> rlineBuses = {};




  bool pressed = false;
  int? routenum;
  bool pressed2 = false;

  @override
  initState() {
    super.initState();
    setCustomMapPin();
    _activatelisteners();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _activatelisteners() {
    var ref = FirebaseDatabase.instance.reference().child('ucpdmarkers');
    ref.orderByChild('time').once().then((snap) {
      data = Map<String, dynamic>.from(snap.value);
      data.forEach((key, value) {
        //print('$key: $value');
        ucpdmarkerobjList.addLast(ucpdMarker(
            key, value['description'], value['time'], value['lat'],
            value['long']));
      });
      setState(() {
        ucpdMarkersetter();
      });
    });
    setState(() {
      FirebaseDatabase.instance
          .reference()
          .child('Buses')
          .child('Cline')
          .onValue
          .listen((event) {
        double lat = event.snapshot.value['lat'];
        double long = event.snapshot.value['long'];
        int ID = event.snapshot.value['ID'];
        busMarkersetter(ID, 'C-Line', lat, long);
      });
      FirebaseDatabase.instance
          .reference()
          .child('Buses')
          .child('Hline')
          .onValue
          .listen((event) {
        double lat = event.snapshot.value['lat'];
        double long = event.snapshot.value['long'];
        int ID = event.snapshot.value['ID'];
        busMarkersetter(ID, 'H-Line', lat, long);
      });
      FirebaseDatabase.instance
          .reference()
          .child('Buses')
          .child('Pline')
          .onValue
          .listen((event) {
        double lat = event.snapshot.value['lat'];
        double long = event.snapshot.value['long'];
        int ID = event.snapshot.value['ID'];
        busMarkersetter(ID, 'P-Line', lat, long);
      });
      FirebaseDatabase.instance
          .reference()
          .child('Buses')
          .child('Rline')
          .onValue
          .listen((event) {
        double lat = event.snapshot.value['lat'];
        double long = event.snapshot.value['long'];
        int ID = event.snapshot.value['ID'];
        busMarkersetter(ID, 'R-Line', lat, long);
      });
    });
  }

  static final CameraPosition _sathersGate = CameraPosition(
    target: LatLng(37.87048700561816, -122.25954814624882),
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(
        children: [

          GoogleMap(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[new Factory<OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer(),),].toSet(),
              initialCameraPosition: _sathersGate,
              polylines: _polylines,
              markers: _finalmarkers.union(busStopmarkers).union(busMarkers),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              compassEnabled: false,
              minMaxZoomPreference: new MinMaxZoomPreference(13, null),
              cameraTargetBounds: new CameraTargetBounds(new LatLngBounds(
                northeast: LatLng(37.884099, -122.236797),
                southwest: LatLng(37.864828, -122.268025),
              ),
              ),
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  polypointsH = coordList().coordListH();
                  polypointsC = coordList().coordListC();
                  polypointsP = coordList().coordListP();
                  polypointsR = coordList().coordListR();
                  setGreyPolylines();
                  _controller.complete(controller);
                  //_controller = controller;
                  controller.setMapStyle(_mapStyle);
                });
              }
          ),
          pressed ? Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: SizeConfig.safeBlockVertical * 9,
                right: SizeConfig.safeBlockHorizontal * 2,
                left: SizeConfig.safeBlockHorizontal * 2),
            child: busDetailCard(routenum),
          ) :
          Container(
            padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 85,
                bottom: SizeConfig.safeBlockVertical * 9),
            child: ListView.builder(
              padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal * 2,
                  right: SizeConfig.safeBlockHorizontal * 2),
              itemCount: 4,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                    child: getBussInArea(index),
                    onTap: () {
                      setState(() {
                        busStopmarkers.clear();
                        busStopmarkerSetter(index);
                        _polylines.clear();
                        setColorpolylines(index);
                        pressed = true;
                        routenum = index;
                      });
                    }
                );
              },
            ),
          ),
          /**
          Container(
            padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 14, left: SizeConfig.safeBlockHorizontal * 5, right: SizeConfig.safeBlockHorizontal * 5),
            child: SizedBox(
              height: SizeConfig.safeBlockVertical * 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black38, spreadRadius: 0, blurRadius: 10),
                  ],
                ),
                child: TextField(
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top:  SizeConfig.safeBlockVertical * 1, bottom: SizeConfig.safeBlockVertical * 1,left: SizeConfig.safeBlockHorizontal * 1, right: SizeConfig.safeBlockHorizontal * 2),
                    hintText: 'Search',
                    hintStyle: TextStyle(fontFamily: 'Gotham', fontWeight: FontWeight.bold, fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
              **/
          Padding(
            padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 5,
                left: SizeConfig.safeBlockHorizontal * 3,
                right: SizeConfig.safeBlockHorizontal * 3),
            child:
            SizedBox(
              height: SizeConfig.safeBlockVertical * 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 4.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Text("BearMap", style: bearMapstyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "assets/busStop.png");
    pinUCPDIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "assets/ucpdIcon.png");
    clineIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "assets/clinebus.png");
    hlineIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "assets/hlinebus.png");
    plineIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "assets/plinebus.png");
    rlineIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "assets/rlinebus.png");
  }

  void busMarkersetter(int ID, String line, double lat, double long) {
    setState(() {
      Marker marker = Marker(
        markerId: MarkerId(ID.toString()),
        position: LatLng(lat, long),
        infoWindow: InfoWindow(title: line),
        icon: busIcongetter(line),
      );
      busMarkers.add(marker);
    });
    if (line == 'C-Line') {
      clineBuses.add(ID.toString());
    } else if (line == 'H-Line') {
      hlineBuses.add(ID.toString());
    } else if (line == 'P-Line') {
      plineBuses.add(ID.toString());
    } else
      rlineBuses.add(ID.toString());
  }

  BitmapDescriptor busIcongetter(String line) {
    if (line == "C-Line") {
      return clineIcon;
    } else if (line == "H-Line") {
      return hlineIcon;
    } else if (line == "P-Line") {
      return plineIcon;
    }
    return rlineIcon;
  }

  void ucpdMarkersetter() {
    setState(() {
      int count = ucpdmarkerobjList.length;
      while (count > 0) {
        ucpdMarker currMark = ucpdmarkerobjList.removeLast();
        String currName = currMark.name;
        String currDescrip = currMark.description;
        String currTime = currMark.time;
        double currlat = currMark.lat;
        double currlong = currMark.long;
        Marker marker = Marker(
          markerId: MarkerId(currName),
          position: LatLng(currlat, currlong),
          infoWindow: InfoWindow(
              title: currName, snippet: '$currDescrip \n $currTime'),
          icon: pinUCPDIcon,
        );
        //print(currMark.toString());
        _finalmarkers.add(marker);
        count = count - 1;
      }
    });
  }

  Widget ucpdMarkerWidget() {
    return Padding(padding: EdgeInsets.only(
        top: SizeConfig.safeBlockVertical * 45,
        left: SizeConfig.safeBlockHorizontal * 5,
        right: SizeConfig.safeBlockHorizontal * 5),
      child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.white,
              boxShadow: [
                new BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                ),
              ],
            ),
          )
      ),
    );
  }

  void busStopmarkerSetter(int index) {
    setState(() {
      if (index == 0) {
        Marker _marker1 = Marker(
          markerId: MarkerId('Downtown Berkeley Bart Stop'),
          position: LatLng(37.87110106321967, -122.26761200332135),
          infoWindow: InfoWindow(title: 'Downtown Berkeley Bart Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker1);
        Marker _marker2 = Marker(
          markerId: MarkerId('University Hall Stop'),
          position: LatLng(37.872721884919144, -122.26593237509515),
          infoWindow: InfoWindow(title: 'University Hall Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker2);
        Marker _marker3 = Marker(
          markerId: MarkerId('Tolman Hall Stop'),
          position: LatLng(37.874440427536406, -122.26414464369127),
          infoWindow: InfoWindow(title: 'Tolman Hall Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker3);
        Marker _marker4 = Marker(
          markerId: MarkerId('North Gate Stop'),
          position: LatLng(37.87494922595155, -122.26043949383795),
          infoWindow: InfoWindow(title: 'North Gate Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker4);
        Marker _marker5 = Marker(
          markerId: MarkerId('Cory Hall Stop'),
          position: LatLng(37.875320399649446, -122.25797491849046),
          infoWindow: InfoWindow(title: 'Cory Hall Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker5);
        Marker _marker6 = Marker(
          markerId: MarkerId('Hearst Mining Circle Stop'),
          position: LatLng(37.8734122221509, -122.25741479013755),
          infoWindow: InfoWindow(title: 'Hearst Mining Circle Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker6);
        Marker _marker7 = Marker(
          markerId: MarkerId('Moffitt Library Stop'),
          position: LatLng(37.87310713951819, -122.26096818386144),
          infoWindow: InfoWindow(title: 'Moffitt Library Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker7);
        Marker _marker8 = Marker(
          markerId: MarkerId('West Circle Stop'),
          position: LatLng(37.87218275086032, -122.26390988097351),
          infoWindow: InfoWindow(title: 'West Circle Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker8);
        Marker _marker9 = Marker(
          markerId: MarkerId('Li Ka Shing Center Stop'),
          position: LatLng(37.871752108011094, -122.26514205468017),
          infoWindow: InfoWindow(title: 'Li Ka Shing Center Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker9);
      }
      else if (index == 1) {
        Marker _marker1 = Marker(
          markerId: MarkerId('Evans Hall Stop'),
          position: LatLng(37.87343509050386, -122.25741098899628),
          infoWindow: InfoWindow(title: 'Evans Hall Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker1);
        Marker _marker2 = Marker(
          markerId: MarkerId('Strawberry Canyon Stop'),
          position: LatLng(37.872620313237476, -122.24634383887849),
          infoWindow: InfoWindow(title: 'Strawberry Canyon Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker2);
        Marker _marker3 = Marker(
          markerId: MarkerId('UC Botanical Garden Stop'),
          position: LatLng(37.87546068755529, -122.23880353266959),
          infoWindow: InfoWindow(title: 'UC Botanical Garden Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker3);
        Marker _marker4 = Marker(
          markerId: MarkerId('Lawrence Hall of Science Stop'),
          position: LatLng(37.88003475554788, -122.24600877662863),
          infoWindow: InfoWindow(title: 'Lawrence Hall of Science Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker4);
        Marker _marker5 = Marker(
          markerId: MarkerId('Space Science Lab/MSRI Stop'),
          position: LatLng(37.88064970105998, -122.24417228114167),
          infoWindow: InfoWindow(title: 'Space Science Lab/MSRI Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker5);
        Marker _marker6 = Marker(
          markerId: MarkerId('Downtown Berkeley Bart Stop'),
          position: LatLng(37.87033967041704, -122.26836106387442),
          infoWindow: InfoWindow(title: 'Downtown Berkeley Bart Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker6);
      }
      else if (index == 2) {
        Marker _marker1 = Marker(
          markerId: MarkerId('Downtown Berkeley Bart Stop'),
          position: LatLng(37.87020186638617, -122.26773532473548),
          infoWindow: InfoWindow(title: 'Downtown Berkeley Bart Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker1);
        Marker _marker2 = Marker(
          markerId: MarkerId('Oxford Street Stop'),
          position: LatLng(37.87271617361611, -122.26595403407735),
          infoWindow: InfoWindow(title: 'Oxford Street Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker2);
        Marker _marker3 = Marker(
          markerId: MarkerId('Tolman Hall Stop'),
          position: LatLng(37.874434625427895, -122.2641416408261),
          infoWindow: InfoWindow(title: 'Tolman Hall Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker3);
        Marker _marker4 = Marker(
          markerId: MarkerId('North Gate Stop'),
          position: LatLng(37.87490562913223, -122.26052863151666),
          infoWindow: InfoWindow(title: 'North Gate Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker4);
        Marker _marker5 = Marker(
          markerId: MarkerId('Cory Hall: Hearst Avenue Stop'),
          position: LatLng(37.87532659434738, -122.25797559152026),
          infoWindow: InfoWindow(title: 'Cory Hall: Hearst Avenue Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker5);
        Marker _marker6 = Marker(
          markerId: MarkerId('Evans Hall Stop'),
          position: LatLng(37.87342342826386, -122.25740660597515),
          infoWindow: InfoWindow(title: 'Evans Hall Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker6);
        Marker _marker7 = Marker(
          markerId: MarkerId('Gayley Stop'),
          position: LatLng(37.87263131926304, -122.25397356765346),
          infoWindow: InfoWindow(title: 'Gayley Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker7);
        Marker _marker8 = Marker(
          markerId: MarkerId('Haas School of Business Stop'),
          position: LatLng(37.87144111791818, -122.2528353566409),
          infoWindow: InfoWindow(title: 'Haas School of Business Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker8);
        Marker _marker9 = Marker(
          markerId: MarkerId('International House Stop'),
          position: LatLng(37.86973912280996, -122.25241884366197),
          infoWindow: InfoWindow(title: 'International House Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker9);
        Marker _marker10 = Marker(
          markerId: MarkerId('Piedmont Avenue Stop'),
          position: LatLng(37.86794303316438, -122.25220382407137),
          infoWindow: InfoWindow(title: 'Piedmont Avenue Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker10);
        Marker _marker11 = Marker(
          markerId: MarkerId('College Ave @ Underhill Stop'),
          position: LatLng(37.866804899099016, -122.25404758996753),
          infoWindow: InfoWindow(title: 'College Ave @ Underhill Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker11);
        Marker _marker12 = Marker(
          markerId: MarkerId('Kroeber Hall Stop'),
          position: LatLng(37.86932734602562, -122.2551476901742),
          infoWindow: InfoWindow(title: 'Kroeber Hall Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker12);
        Marker _marker13 = Marker(
          markerId: MarkerId('Hearst Memorial Gym Stop'),
          position: LatLng(37.86904707840791, -122.25719287648904),
          infoWindow: InfoWindow(title: 'Hearst Memorial Gym Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker13);
        Marker _marker14 = Marker(
          markerId: MarkerId('Sproul Hall: Bancroft Stop'),
          position: LatLng(37.86852816184033, -122.2612286293471),
          infoWindow: InfoWindow(title: 'Sproul Hall: Bancroft Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker14);
        Marker _marker15 = Marker(
          markerId: MarkerId('RSF Stop'),
          position: LatLng(37.86817778979381, -122.26408421117223),
          infoWindow: InfoWindow(title: 'RSF Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker15);
        Marker _marker16 = Marker(
          markerId: MarkerId('Banway Building Stop'),
          position: LatLng(37.86768297464692, -122.26749898287079),
          infoWindow: InfoWindow(title: 'Banway Building Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker16);
        Marker _marker17 = Marker(
          markerId: MarkerId('Kittredge Stop'),
          position: LatLng(37.868324538326256, -122.26770299282008),
          infoWindow: InfoWindow(title: 'Kittredge Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker17);
      }
      else if (index == 3) {
        Marker _marker1 = Marker(
          markerId: MarkerId('Hearst Mining Circle Stop'),
          position: LatLng(37.873433815586225, -122.257420967197385),
          infoWindow: InfoWindow(title: 'Hearst Mining Circle Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker1);
        Marker _marker2 = Marker(
          markerId: MarkerId('Greek Theatre Stop'),
          position: LatLng(37.87423794617746, -122.25553919039825),
          infoWindow: InfoWindow(title: 'Greek Theatre Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker2);
        Marker _marker3 = Marker(
          markerId: MarkerId('Cory Hall Stop'),
          position: LatLng(37.87546790560681, -122.25799230367718),
          infoWindow: InfoWindow(title: 'Cory Hall Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker3);
        Marker _marker4 = Marker(
          markerId: MarkerId('North Gate Stop'),
          position: LatLng(37.87514564051262, -122.2603468092355),
          infoWindow: InfoWindow(title: 'North Gate Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker4);
        Marker _marker5 = Marker(
          markerId: MarkerId('Hearst & Arch Stop'),
          position: LatLng(37.87468381068604, -122.26393885371105),
          infoWindow: InfoWindow(title: 'Hearst & Arch Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker5);
        Marker _marker6 = Marker(
          markerId: MarkerId('Hearst & Oxford Stop'),
          position: LatLng(37.873834605053744, -122.26636685759681),
          infoWindow: InfoWindow(title: 'Hearst & Oxford Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker6);
        Marker _marker7 = Marker(
          markerId: MarkerId('Walnut & University Stop'),
          position: LatLng(37.87241440587503, -122.26721391888965),
          infoWindow: InfoWindow(title: 'Walnut & University Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker7);
        Marker _marker8 = Marker(
          markerId: MarkerId('Downtown Berkeley Bart Stop'),
          position: LatLng(37.87011676156149, -122.26811846305121),
          infoWindow: InfoWindow(title: 'Addison & Shattuck Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker8);
        Marker _marker9 = Marker(
          markerId: MarkerId('Shattuck & Kittredge Stop'),
          position: LatLng(37.86835454301324, -122.2680446426076),
          infoWindow: InfoWindow(title: 'Shattuck & Kittredge Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker9);
        Marker _marker10 = Marker(
          markerId: MarkerId('Shattuck & Channing Stop'),
          position: LatLng(37.865780132696926, -122.26723001683152),
          infoWindow: InfoWindow(title: 'Shattuck & Channing Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker10);
        Marker _marker11 = Marker(
          markerId: MarkerId('Channing & Ellsworth Stop'),
          position: LatLng(37.866303817354485, -122.26316866394069),
          infoWindow: InfoWindow(title: 'Channing & Ellsworth Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker11);
        Marker _marker12 = Marker(
          markerId: MarkerId('Unit 3 Stop'),
          position: LatLng(37.86678013426208, -122.25948428484769),
          infoWindow: InfoWindow(title: 'Unit 3 Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker12);
        Marker _marker13 = Marker(
          markerId: MarkerId('Bowdwitch Stop'),
          position: LatLng(37.86712317811682, -122.25679779467286),
          infoWindow: InfoWindow(title: 'Bowdwitch Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker13);
        Marker _marker14 = Marker(
          markerId: MarkerId('Unit 1 Stop'),
          position: LatLng(37.867413755193866, -122.25446405007588),
          infoWindow: InfoWindow(title: 'Unit 1 Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker14);
        Marker _marker15 = Marker(
          markerId: MarkerId('Unit 2 Stop'),
          position: LatLng(37.86597700181667, -122.25404484509225),
          infoWindow: InfoWindow(title: 'Unit 2 Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker15);
        Marker _marker16 = Marker(
          markerId: MarkerId('Clark Kerr Stop'),
          position: LatLng(37.865924624913625, -122.2499678902707),
          infoWindow: InfoWindow(title: 'Clark Kerr Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker16);
        Marker _marker17 = Marker(
          markerId: MarkerId('Channing Circle Stop'),
          position: LatLng(37.86808242128412, -122.25183335157068),
          infoWindow: InfoWindow(title: 'Channing Circle Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker17);
        Marker _marker18 = Marker(
          markerId: MarkerId('International House Stop'),
          position: LatLng(37.869791085416466, -122.25212393761625),
          infoWindow: InfoWindow(title: 'International House Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker18);
        Marker _marker19 = Marker(
          markerId: MarkerId('Haas: School of Business Stop'),
          position: LatLng(37.8714357418037, -122.2525734236123),
          infoWindow: InfoWindow(title: 'Haas: School of Business Stop'),
          icon: pinLocationIcon,
        );
        busStopmarkers.add(_marker19);
      }
    });
  }

  void setColorpolylines(int index) {
    if (index == 0) {
      setState(() {
        _polylines.add(
          Polyline(
            visible: true,
            width: 5,
            jointType: JointType.bevel,
            polylineId: PolylineId('C_line'),
            color: Color(0xFF86edbe),
            points: polypointsC,
            startCap: Cap.roundCap,
            endCap: Cap.buttCap,
          ),
        );
      });
    } else if (index == 1) {
      setState(() {
        _polylines.add(
          Polyline(
            visible: true,
            width: 5,
            jointType: JointType.bevel,
            polylineId: PolylineId('H_line'),
            color: Color(0xFFed86e5),
            points: polypointsH,
            startCap: Cap.roundCap,
            endCap: Cap.buttCap,
          ),
        );
      });
    } else if (index == 2) {
      setState(() {
        _polylines.add(
          Polyline(
            visible: true,
            width: 5,
            jointType: JointType.bevel,
            polylineId: PolylineId('P_line'),
            color: Color(0xFF86c7ed),
            points: polypointsP,
            startCap: Cap.roundCap,
            endCap: Cap.buttCap,
          ),
        );
      });
    } else if (index == 3) {
      setState(() {
        _polylines.add(
          Polyline(
            visible: true,
            width: 5,
            jointType: JointType.bevel,
            polylineId: PolylineId('R_line'),
            color: Color(0xFFfbef6e),
            points: polypointsR,
            startCap: Cap.roundCap,
            endCap: Cap.buttCap,
          ),
        );
      });
    }
  }

  void setGreyPolylines() {
    setState(() {
      _polylines.add(
        Polyline(
          visible: true,
          width: 5,
          jointType: JointType.bevel,
          polylineId: PolylineId('H_line'),
          color: Color(0xFF8d8d8d),
          points: polypointsH,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap,
        ),
      );
      _polylines.add(
        Polyline(
          visible: true,
          width: 5,
          jointType: JointType.bevel,
          polylineId: PolylineId('C_line'),
          color: Color(0xFF8d8d8d),
          points: polypointsC,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap,
        ),
      );
      _polylines.add(
        Polyline(
          visible: true,
          width: 5,
          jointType: JointType.bevel,
          polylineId: PolylineId('P_line'),
          color: Color(0xFF8d8d8d),
          points: polypointsP,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap,
        ),
      );
      _polylines.add(
        Polyline(
          visible: true,
          width: 5,
          jointType: JointType.bevel,
          polylineId: PolylineId('R_line'),
          color: Color(0xFF8d8d8d),
          points: polypointsR,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap,
        ),
      );
    });
  }

  Stack busDetailCard(int? index) {
    Bus bus = getBuseLines(index)!;
    String hours = bus.hours;
    String interval = bus.interval;
    String info = bus.info;
    return Stack(
        children: <Widget>[
          Container(
          height: SizeConfig.safeBlockVertical * 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.white,
            boxShadow: [
              new BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
              ),
            ],
          ),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    top: SizeConfig.safeBlockHorizontal * 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              top: SizeConfig.safeBlockHorizontal * 3,
                              left: SizeConfig.safeBlockHorizontal * 4,
                              right: SizeConfig.safeBlockHorizontal * 5),
                          child: CircleAvatar(
                            backgroundImage: bus.profilePic,
                          ),
                        ), Container(
                          padding: EdgeInsets.only(
                              top: SizeConfig.safeBlockHorizontal * 3),
                          child: Text(bus.name, style: techCardTitleStyle),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            busStopmarkers.clear();
                            _polylines.clear();
                            setGreyPolylines();
                            pressed = false;
                            routenum = 0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 3,
                    left: SizeConfig.safeBlockHorizontal * 3,
                    right: SizeConfig.safeBlockHorizontal * 3),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 15,
                        width: SizeConfig.safeBlockHorizontal * 40,
                        child: Container(
                          child: Column(
                            children: [
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: SizeConfig.safeBlockVertical * 0.5,
                                      left: SizeConfig.safeBlockHorizontal * 1,
                                      right: SizeConfig.safeBlockHorizontal *
                                          1),
                                  child: Text("Operation:",
                                      style: techCardBoldBodyStyle),
                                ),
                              ),
                              Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: SizeConfig.safeBlockVertical * 2,
                                        left: SizeConfig.safeBlockHorizontal *
                                            1,
                                        right: SizeConfig.safeBlockHorizontal *
                                            1),
                                    child: Text(
                                        "$hours", style: techCardBodyStyle,
                                        textAlign: TextAlign.center),
                                  )
                              ),
                              Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: SizeConfig.safeBlockVertical * 0.5,
                                        left: SizeConfig.safeBlockHorizontal *
                                            1,
                                        right: SizeConfig.safeBlockHorizontal *
                                            1),
                                    child: Text(
                                        "$interval", style: techCardBodyStyle,
                                        textAlign: TextAlign.center),
                                  )
                              ),
                            ],
                          ),
                          decoration: new BoxDecoration(
                            color: Colors.white,
                            //Color(0xFFf2ede1),
                            //border:  Border.all(width: 1, style: BorderStyle.solid, color: Color(0xff003262)),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black38,
                                  spreadRadius: 0,
                                  blurRadius: 2),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 15,
                        width: SizeConfig.safeBlockHorizontal * 40,
                        child: Container(
                          child: Container(
                            child: Column(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: SizeConfig.safeBlockVertical * 0.5,
                                        left: SizeConfig.safeBlockHorizontal *
                                            1,
                                        right: SizeConfig.safeBlockHorizontal *
                                            1),
                                    child: Text(
                                        "Fair:", style: techCardBoldBodyStyle),
                                  ),
                                ),
                                Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: SizeConfig.safeBlockVertical * 2,
                                          left: SizeConfig.safeBlockHorizontal *
                                              1,
                                          right: SizeConfig
                                              .safeBlockHorizontal * 1),
                                      child: Text(r"Free with Pass* · $1",
                                          style: techCardBodyStyle),
                                    )
                                ),
                              ],
                            ),
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              //Color(0xFFf2ede1),
                              //  Border.all(width: 1, style: BorderStyle.solid, color: Color(0xff003262)),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black38,
                                    spreadRadius: 0,
                                    blurRadius: 2),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]
                ),
              ),
              Spacer(flex: 1,),
              Padding(
                padding: EdgeInsets.only(
                    left: SizeConfig.safeBlockHorizontal * 3,
                    right: SizeConfig.safeBlockHorizontal * 3,
                    bottom: SizeConfig.safeBlockVertical * 1),
                child: SizedBox(
                  height: SizeConfig.safeBlockVertical * 5,
                  width: SizeConfig.safeBlockHorizontal * 90,
                  child: Container(
                    child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: SizeConfig.safeBlockVertical * 0.1,
                              left: SizeConfig.safeBlockHorizontal * 1,
                              right: SizeConfig.safeBlockHorizontal * 1),
                          child: Text(
                              "*Passes honored for free shuttle ride: Bear Transit Shuttle Pass; Cal 1 Card ID; EasyPass; Emeriti ID.",
                              style: techCardSmallStyle,
                              textAlign: TextAlign.justify),
                        )
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        ]
    );
  }

  Widget busCard(Bus bus) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 2),
      margin: EdgeInsets.only(right: SizeConfig.safeBlockHorizontal * 3),
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
        boxShadow: [
          new BoxShadow(
            color: Colors.grey,
            blurRadius: 5.0,
          ),
        ],
      ),
      child:
      Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    top: SizeConfig.safeBlockHorizontal * 2,
                    bottom: SizeConfig.safeBlockHorizontal * 2,
                    left: SizeConfig.safeBlockHorizontal * 2,
                    right: SizeConfig.safeBlockHorizontal * 5),
                child: CircleAvatar(
                  backgroundImage: bus.profilePic,
                ),
              ),
              Text(bus.name, style: techCardTitleStyle,),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: SizeConfig.safeBlockHorizontal * 5),
            child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Text("Status:  ", style: techCardSubTitleStyle,),
                      Text(busStatusGetter(bus.name), style: statusStyles[busStatusGetter(bus.name)])
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getBussInArea(int index) {
    Bus bus = getBuseLines(index)!;
    return busCard(bus);
  }

  Bus? getBuseLines(int? index) {
    int? i = index;
    if (i == 0) {
      AssetImage profilePic = new AssetImage("assets/c_line.png");
      Bus myBus = new Bus("C-Line", "6:45am to 11:15am;\n 4:15pm to 7:15pm",
          "Runs at 20 minute frequncies.", 2, profilePic, "");
      return myBus;
    } else if (i == 1) {
      AssetImage profilePic = new AssetImage("assets/h_line.png");
      Bus myBus = new Bus(
          "H-Line", "7:35am to 7:25pm", "Runs at 30 minute frequencies. ", 2,
          profilePic,
          "The first trip starts and the last two trips start\n & end at Downtown Berkeley BART Station");
      return myBus;
    } else if (i == 2) {
      AssetImage profilePic = new AssetImage("assets/p_line.png");
      Bus myBus = new Bus(
          "P-Line", "7:00am to 7:30pm", "Runs at 30 minute frequencies.", 2,
          profilePic,
          "Last full trip leaves Downtown Berkeley\n BART at 7:00 p.m.");
      return myBus;
    } else if (i == 3) {
      AssetImage profilePic = new AssetImage("assets/r_line.png");
      Bus myBus = new Bus(
          "R-Line", "7:15am to 6:15pm", "Runs at 30 minute frequencies.", 2,
          profilePic,
          "Last full trip from Downtown Berkeley BART\n at 6:15pm.");
      return myBus;
    }
    return null;
  }

  String busStatusGetter(String busline) {
    if (busline == 'C-Line'){
      if (clineBuses.isNotEmpty) {
        return "Available";
      }
    }else if (busline == 'H-Line'){
      if (hlineBuses.isNotEmpty) {
        return "Available";
      }
    }else if (busline == 'P-Line'){
      if (plineBuses.isNotEmpty) {
        return "Available";
      }
    }else if (busline == 'R-Line'){
      if (rlineBuses.isNotEmpty) {
        return "Available";
      }
    }
    return 'Unavailable';
    }

  Map statusStyles = {
    'Available': statusAvailableStyle,
    'Unavailable': statusUnavailableStyle
  };

}

