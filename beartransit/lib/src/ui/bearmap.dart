import 'dart:async';

import 'package:beartransit/src/blocs/busWidget_bloc.dart';
import 'package:beartransit/src/blocs/busWidget_event.dart';
import 'package:beartransit/src/blocs/busWidget_state.dart';
import 'package:beartransit/src/blocs/bus_bloc.dart';
import 'package:beartransit/src/blocs/bus_state.dart';
import 'package:beartransit/src/blocs/ucpdmarker_bloc.dart';
import 'package:beartransit/src/blocs/ucpdmarker_state.dart';
import 'package:beartransit/src/models/busLine.dart';
import 'package:beartransit/src/resources/functions.dart';
import 'package:beartransit/src/resources/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../app.dart';

class bearmap extends StatefulWidget {
  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<bearmap> {
  Completer<GoogleMapController> _controller = Completer();
  String? _mapStyle;

  late ucpdMarkerBloc ucpdbloc;
  late busBloc busbloc;
  late Buswidgetbloc buswidgetBloc;

  late Set<Polyline> polylines = {};

  Set<Marker> cLine = {};
  Set<Marker> hLine = {};
  Set<Marker> pLine = {};
  Set<Marker> rLine = {};
  Set<Marker> ucpdMarkers = {};

  busLine c_Line = returnCLine();
  busLine h_Line = returnHLine();
  busLine p_Line = returnPLine();
  busLine r_Line = returnRLine();

  static final CameraPosition _sathersGate = CameraPosition(
    target: LatLng(37.87048700561816, -122.25954814624882),
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    ucpdbloc = BlocProvider.of(context);
    busbloc = BlocProvider.of(context);
    rootBundle
        .loadString('lib/src/resources/assets/map_style.txt')
        .then((string) {
      _mapStyle = string;
    });
    buswidgetBloc = Buswidgetbloc(c_Line, h_Line, p_Line, r_Line);
  }

  @override
  void dispose() {
    super.dispose();
    ucpdbloc.close();
    busbloc.close();
    buswidgetBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(
        children: [
          MultiBlocListener(
            listeners: [
              BlocListener<ucpdMarkerBloc, ucpdmarkerState>(
                listener: (context, data) {
                  if (data is ucpdmarkerLoadedState) {
                    ucpdMarkers = data.ucpdmarkers;
                    setState(() {
                      _controller.future;
                    });
                  }
                  ;
                },
              ),
              BlocListener<busBloc, busState>(
                listener: (context, data) {
                  if (data is busLoadedState) {
                    cLine = data.cLine;
                    hLine = data.hLine;
                    pLine = data.pLine;
                    rLine = data.rLine;
                    setState(() {
                      _controller.future;
                    });
                  }
                },
              )
            ],
            child: Stack(
              children: [
                GoogleMap(
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                      new Factory<OneSequenceGestureRecognizer>(
                        () => new EagerGestureRecognizer(),
                      ),
                    ].toSet(),
                    initialCameraPosition: _sathersGate,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    compassEnabled: false,
                    polylines: polylines,
                    markers: ucpdMarkers
                        .union(cLine)
                        .union(hLine)
                        .union(pLine)
                        .union(rLine),
                    minMaxZoomPreference: new MinMaxZoomPreference(13, null),
                    cameraTargetBounds: new CameraTargetBounds(
                      new LatLngBounds(
                        northeast: LatLng(37.884099, -122.236797),
                        southwest: LatLng(37.864828, -122.268025),
                      ),
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      setState(() {
                        _controller.complete(controller);
                        controller.setMapStyle(_mapStyle);
                      });
                    }),
                BlocBuilder<Buswidgetbloc, BuswidgetState>(
                    bloc: buswidgetBloc,
                    builder: (context, state) {
                      return busWidgetbuilder(state);
                    }),
                Padding(
                  padding: EdgeInsets.only(
                      top: SizeConfig.safeBlockVertical * 5,
                      left: SizeConfig.safeBlockHorizontal * 3,
                      right: SizeConfig.safeBlockHorizontal * 3),
                  child: SizedBox(
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
                              color: Colors.black38,
                              spreadRadius: 0,
                              blurRadius: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.only(top: SizeConfig.safeBlockVertical * 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      new Text("BearMap", style: bearTitlestyle),
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

  Widget busWidgetbuilder(BuswidgetState state) {
    if (state is BusCardWidget) {
      polylines = setGreyPolylines();
      return Container(
        padding: EdgeInsets.only(
            top: SizeConfig.safeBlockVertical * 80,
            bottom: SizeConfig.safeBlockVertical * 4.5),
        child: ListView.builder(
          padding: EdgeInsets.only(
              left: SizeConfig.safeBlockHorizontal * 2,
              right: SizeConfig.safeBlockHorizontal * 2),
          itemCount: 4,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              child: busCard(
                  [state.cline, state.hline, state.pline, state.rline]
                      .elementAt(index),
                  [cLine, hLine, pLine, rLine].elementAt(index)),
              onTap: () {
                polylines = setColorpolylines(index);
                buswidgetBloc.add(ChangeBusWidget(index));
                setState(() {
                  _controller.future;
                });
              },
            );
          },
        ),
      );
    } else if (state is BusDetailCWidget) {
      return busDetailCard(state.line);
    } else if (state is BusDetailHWidget) {
      return busDetailCard(state.line);
    } else if (state is BusDetailPWidget) {
      return busDetailCard(state.line);
    } else if (state is BusDetailRWidget) {
      return busDetailCard(state.line);
    } else {
      return Text('ERROR', style: TitleStyle);
    }
  }

  Widget busCard(busLine bus, Set<Marker> line) {
    String status;
    TextStyle statusStyle;

    if (line.isNotEmpty) {
      status = 'Available';
      statusStyle = statusAvailableStyle;
    } else {
      status = 'Unavailable';
      statusStyle = statusUnavailableStyle;
    }

    return Container(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 2),
      margin: EdgeInsets.only(right: SizeConfig.safeBlockHorizontal * 3),
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
      ),
      child: Column(
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
              Text(
                bus.name,
                style: TitleStyle,
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: SizeConfig.safeBlockHorizontal * 5),
            child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Text("Status:  ", style: SubTitleStyle),
                      Text(status, style: statusStyle)
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

  Widget busDetailCard(busLine line) {
    String hours = line.hours;
    String interval = line.interval;
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(
          bottom: SizeConfig.safeBlockVertical * 5,
          right: SizeConfig.safeBlockHorizontal * 2,
          left: SizeConfig.safeBlockHorizontal * 2),
      child: Stack(children: <Widget>[
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
                padding:
                    EdgeInsets.only(top: SizeConfig.safeBlockHorizontal * 1),
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
                            backgroundImage: line.profilePic,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              top: SizeConfig.safeBlockHorizontal * 3),
                          child: Text(line.name, style: TitleStyle),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          polylines = setGreyPolylines();
                          buswidgetBloc.add(ChangeBusWidget(5));
                          setState(() {
                            _controller.future;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: SizeConfig.safeBlockVertical * 3,
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
                                      right:
                                          SizeConfig.safeBlockHorizontal * 1),
                                  child:
                                      Text("Operation:", style: BoldBodyStyle),
                                ),
                              ),
                              Center(
                                  child: Padding(
                                padding: EdgeInsets.only(
                                    top: SizeConfig.safeBlockVertical * 2,
                                    left: SizeConfig.safeBlockHorizontal * 1,
                                    right: SizeConfig.safeBlockHorizontal * 1),
                                child: Text("$hours",
                                    style: BodyStyle,
                                    textAlign: TextAlign.center),
                              )),
                              Center(
                                  child: Padding(
                                padding: EdgeInsets.only(
                                    top: SizeConfig.safeBlockVertical * 0.5,
                                    left: SizeConfig.safeBlockHorizontal * 1,
                                    right: SizeConfig.safeBlockHorizontal * 1),
                                child: Text("$interval",
                                    style: BodyStyle,
                                    textAlign: TextAlign.center),
                              )),
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
                                  blurRadius: 1),
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
                                        left:
                                            SizeConfig.safeBlockHorizontal * 1,
                                        right:
                                            SizeConfig.safeBlockHorizontal * 1),
                                    child: Text("Fair:", style: BoldBodyStyle),
                                  ),
                                ),
                                Center(
                                    child: Padding(
                                  padding: EdgeInsets.only(
                                      top: SizeConfig.safeBlockVertical * 2,
                                      left: SizeConfig.safeBlockHorizontal * 1,
                                      right:
                                          SizeConfig.safeBlockHorizontal * 1),
                                  child: Text(r"Free with Pass* · $1",
                                      style: BodyStyle),
                                )),
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
                                    blurRadius: 1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
              Spacer(
                flex: 1,
              ),
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
                          style: SmallStyle,
                          textAlign: TextAlign.justify),
                    )),
                  ),
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }
}
