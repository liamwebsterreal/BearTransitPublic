import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class ucpdmarkerEvents {}

class HasDataEvent extends ucpdmarkerEvents {
  Set<Marker> ucpdmarkers;

  HasDataEvent(this.ucpdmarkers);
}