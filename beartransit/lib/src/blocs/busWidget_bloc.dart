import 'package:beartransit/src/models/busLine.dart';
import 'package:bloc/bloc.dart';
import 'busWidget_state.dart';
import 'busWidget_event.dart';

class Buswidgetbloc extends Bloc<ChangeBusWidget, BuswidgetState> {
  busLine cline;
  busLine hline;
  busLine pline;
  busLine rline;


  Buswidgetbloc(this.cline,this.hline,this.pline,this.rline) : super(BusCardWidget(cline,hline,pline,rline)) {}

  @override
  Stream<BuswidgetState> mapEventToState(ChangeBusWidget event) async* {
    if (event.index == 0) {
      yield BusDetailCWidget(cline);
    } else if (event.index == 1) {
      yield BusDetailHWidget(hline);
    } else if (event.index == 2) {
      yield BusDetailPWidget(pline);
    } else if (event.index == 3) {
      yield BusDetailRWidget(rline);
    } else {
      yield BusCardWidget(cline,hline,pline,rline);
    }
  }

  @override
  void dispose() {
    super.close();
  }
}