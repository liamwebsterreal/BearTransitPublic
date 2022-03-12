import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'ucpdmarker_event.dart';
import 'ucpdmarker_state.dart';
import 'package:beartransit/src/repositories/ucpdmarkerRepository.dart';

class ucpdMarkerBloc extends Bloc<HasDataEvent, ucpdmarkerState> {

  final ucpdmarkerRepository repository;
  late Set<Marker> ucpdMarkers;


  ucpdMarkerBloc(this.repository) : super(ucpdmarkerLoadingState()) {
    repository.ucpdmarkers().listen((data) => add(HasDataEvent(data)));
    ucpdMarkers = {};
  }

  @override
  Stream<ucpdmarkerState> mapEventToState(HasDataEvent event) async* {
    if (event is HasDataEvent) {
      ucpdMarkers = event.ucpdmarkers;
      yield ucpdmarkerLoadedState(ucpdMarkers);
    }
  }

  @override
  void dispose() {
    repository.dispose();
    super.close();
  }
}