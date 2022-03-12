import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class ucpdmarkerRepository {
  late BitmapDescriptor pinUCPDIcon;
  Stream<Set<Marker>> ucpdmarkers();
  void dispose();
  void refresh();
}

class ucpdmarkerRepositoryFirebase extends ucpdmarkerRepository {
  StreamController<Set<Marker>> _loadedData = StreamController();
  late BitmapDescriptor pinUCPDIcon;

  final _cache = new Set<Marker>();

  void setCustomMapPin() async {
    pinUCPDIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 3),
        "lib/src/resources/assets/ucpdIcon.png");
  }

  @override
  void dispose() {
    _loadedData.close();
  }

  @override
  void refresh() {
    setCustomMapPin();
    var ref = FirebaseDatabase.instance.reference().child('ucpdmarkers');
    ref.onValue.listen((event) {
      _cache.clear();
      Map<String, dynamic> _data = {};
      _data = Map<String, dynamic>.from(event.snapshot.value);
      _data.forEach((key, value) {
        //print('$key: $value');
        String description = value['description'];
        String time = value['time'];
        _cache.add(Marker(
          markerId: MarkerId(key),
          position: LatLng(value['lat'], value['long']),
          infoWindow: InfoWindow(title: key, snippet: '$description \n $time'),
          icon: pinUCPDIcon,
        ));
      });
      _loadedData.add(_cache);
    });
  }

  @override
  Stream<Set<Marker>> ucpdmarkers() => _loadedData.stream;
}
