import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class ucpdmarkerState {}

class ucpdmarkerLoadingState extends ucpdmarkerState{}

class ucpdmarkerLoadedState extends ucpdmarkerState{
  Set<Marker> ucpdmarkers;
  ucpdmarkerLoadedState(this.ucpdmarkers);
}