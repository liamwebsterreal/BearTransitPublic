abstract class BuswidgetEvent {}

class ChangeBusWidget extends BuswidgetEvent {
  int index;
  ChangeBusWidget(this.index);
}