import 'package:flutter_render_world/div/ui-config/layout.dart';
import 'div.dart';

abstract class ViewPort extends Layout {
  ViewPort(List<DIV> children): super(children);
}

class Scroll extends ViewPort {
  Scroll.vertical(List<DIV> children): super(children);

  Scroll.horizontal(List<DIV> children): super(children);
}

class Recycler extends ViewPort {
  Recycler.vertical(List<DIV> children): super(children);
  Recycler.horizontal(List<DIV> children): super(children);
}