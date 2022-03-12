import 'dart:async';

import 'package:beartransit/src/blocs/bus_bloc.dart';
import 'package:beartransit/src/blocs/ucpdmarker_bloc.dart';
import 'package:beartransit/src/repositories/busRepository.dart';
import 'package:beartransit/src/repositories/ucpdmarkerRepository.dart';
import 'package:beartransit/src/ui/bearmap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

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
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firestore Demo app',
      theme: ThemeData(
      ),
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ucpdmarkerRepository>(create: (context) => ucpdmarkerRepositoryFirebase()..refresh()),
          RepositoryProvider<busRepository>(create: (context) => busRepositoryFirebase()..refresh()),
        ],
        child:MultiBlocProvider(
            providers: [
              BlocProvider<ucpdMarkerBloc>(
                create: (context) => ucpdMarkerBloc(RepositoryProvider.of(context)),
              ),
              BlocProvider<busBloc>(
                create: (context) => busBloc(RepositoryProvider.of(context)),
              ),
            ],
            child: bearmap()),
      ),
    );
  }
}
