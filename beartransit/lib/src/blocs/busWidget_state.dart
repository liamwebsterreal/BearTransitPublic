import 'package:beartransit/src/models/busLine.dart';

abstract class BuswidgetState {}

class BusCardWidget extends BuswidgetState {
  busLine cline;
  busLine hline;
  busLine pline;
  busLine rline;
  BusCardWidget(this.cline,this.hline,this.pline,this.rline);
}

class BusDetailCWidget extends BuswidgetState {
  busLine line;
  BusDetailCWidget(this.line);
}
class BusDetailHWidget extends BuswidgetState {
  busLine line;
  BusDetailHWidget(this.line);
}
class BusDetailPWidget extends BuswidgetState {
  busLine line;
  BusDetailPWidget(this.line);
}
class BusDetailRWidget extends BuswidgetState {
  busLine line;
  BusDetailRWidget(this.line);
}