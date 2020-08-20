import 'package:flutter_render_world/div/ui-config/layout.dart';

import 'box.dart';
import 'colors.dart';
import 'content.dart';

class DIV {
  Box box;
  Content content;

  DIV(SizeSpec width, SizeSpec height):
        box = Box()
          ..width = width
          ..height = height;

  set padding(BoxInsets padding) => box.padding = padding;

  set margin(BoxInsets margin) => box.margin = margin;

  set background(Color background) => box.background = background;

  set border(Border border) => box.border = border;
}

test() {
  DIV div = DIV(SizeSpec.matchParent(), SizeSpec.matchParent())
    ..padding = BoxInsets.all(10)
    ..margin = BoxInsets.only(left: 10, top: 10)
    ..background = Colors.amber
    ..border = Border()
    ..content = Text();

  DIV div1 = DIV(SizeSpec.matchParent(), SizeSpec.matchParent())
    ..padding = BoxInsets.all(10)
    ..margin = BoxInsets.only(left: 10, top: 10)
    ..background = Colors.amber
    ..border = Border()
    ..content = Linear.vertical([]);
}
