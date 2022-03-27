import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class busState {}

class busLoadingState extends busState {}

class busLoadedState extends busState {
  Set<Marker> cLine;
  Set<Marker> hLine;
  Set<Marker> pLine;
  Set<Marker> rLine;
  busLoadedState(this.cLine, this.hLine, this.pLine, this.rLine);
}
