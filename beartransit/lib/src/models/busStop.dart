import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class busStop {
  late String name;
  late AssetImage busstopmarker;
  late int lat;
  late int long;
  busStop(this.name, this.busstopmarker, this.lat, this.long);
}
