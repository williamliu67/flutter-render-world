import 'package:flutter_render_world/div/ui-config/div.dart';

import 'content.dart';

abstract class Layout extends Content {
  List<DIV> children;

  Layout(this.children);
}

class Linear extends Layout {

  Linear.vertical(List<DIV> children): super(children);

  Linear.horizontal(List<DIV> children): super(children);
}

class Frame extends Layout {

  Frame(List<DIV> children): super(children);
}

class Weight extends Layout {

  Weight.vertical(List<DIV> children): super(children);

  Weight.horizontal(List<DIV> children): super(children);
}

class Relative extends Layout {
  Relative(List<DIV> children): super(children);
}

class Flex extends Layout {
  Flex(List<DIV> children): super(children);
}