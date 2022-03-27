import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'bus_event.dart';
import 'bus_state.dart';
import 'package:beartransit/src/repositories/busRepository.dart';

class busBloc extends Bloc<HasDataEvent, busState> {
  final busRepository repository;
  late Set<Marker> cLine;
  late Set<Marker> hLine;
  late Set<Marker> pLine;
  late Set<Marker> rLine;

  busBloc(this.repository) : super(busLoadingState()) {
    repository.buses().listen((data) => add(HasDataEvent(data)));
    cLine = {};
    hLine = {};
    pLine = {};
    rLine = {};
  }

  @override
  Stream<busState> mapEventToState(HasDataEvent event) async* {
    if (event is HasDataEvent) {
      cLine.clear();
      hLine.clear();
      pLine.clear();
      rLine.clear();
      event.busMarkers.forEach((element) {
        if (int.parse(element.markerId.value) < 100) {
          cLine.add(element);
        } else if (int.parse(element.markerId.value) < 200) {
          hLine.add(element);
        } else if (int.parse(element.markerId.value) < 300) {
          pLine.add(element);
        } else {
          rLine.add(element);
        }
      });
      yield busLoadedState(cLine, hLine, pLine, rLine);
    }
  }

  @override
  void dispose() {
    repository.dispose();
    super.close();
  }
}
