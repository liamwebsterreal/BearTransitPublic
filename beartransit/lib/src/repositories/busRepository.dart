import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class busRepository {
  late BitmapDescriptor clineIcon;
  late BitmapDescriptor hlineIcon;
  late BitmapDescriptor plineIcon;
  late BitmapDescriptor rlineIcon;
  Stream<Set<Marker>> buses();
  void dispose();
  void refresh();
}

class busRepositoryFirebase extends busRepository {
  StreamController<Set<Marker>> _loadedData = StreamController();

  final _cache = new Set<Marker>();

  late final BitmapDescriptor clineIcon;
  late final BitmapDescriptor hlineIcon;
  late final BitmapDescriptor plineIcon;
  late final BitmapDescriptor rlineIcon;

  void setCustomMapPin() async {
    clineIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 3),
        "lib/src/resources/assets/clinebus.png");
    hlineIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 3),
        "lib/src/resources/assets/hlinebus.png");
    plineIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 3),
        "lib/src/resources/assets/plinebus.png");
    rlineIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 3),
        "lib/src/resources/assets/rlinebus.png");
  }

  @override
  void dispose() {
    _loadedData.close();
  }

  @override
  void refresh() {
    setCustomMapPin();
    var ref = FirebaseDatabase.instance.reference().child('buses');
    ref.onValue.listen((event) {
      _cache.clear();
      Map<String, dynamic> _data = {};
      _data = Map<String, dynamic>.from(event.snapshot.value);
      _data.forEach((key, value) {
        //print('$key: $value');
        _cache.add(Marker(
          anchor: Offset(0.5, 0.5),
          markerId: MarkerId(key),
          position: LatLng(value['lat'], value['long']),
          infoWindow: InfoWindow(title: value['capacity']),
          icon: busIcongetter(int.parse(key)),
        ));
      });
      _loadedData.add(_cache);
    });
  }

  BitmapDescriptor busIcongetter(int line) {
    if (line < 100) {
      return clineIcon;
    } else if (line < 200) {
      return hlineIcon;
    } else if (line < 300) {
      return plineIcon;
    }
    return rlineIcon;
  }

  @override
  Stream<Set<Marker>> buses() => _loadedData.stream;
}
