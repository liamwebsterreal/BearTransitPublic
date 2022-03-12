import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class busEvents {}

class HasDataEvent extends busEvents {
  Set<Marker> busMarkers;

  HasDataEvent(this.busMarkers);

}
