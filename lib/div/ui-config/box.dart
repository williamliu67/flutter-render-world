import 'dart:math' as math;

import 'package:flutter_render_world/div/ui-config/colors.dart';

class SizeSpec {
  double _value;
  MeasureSpec measureSpec;

  SizeSpec(this._value) : measureSpec = MeasureSpec.EXACTLY;

  SizeSpec.wrapContent() : measureSpec = MeasureSpec.AT_MOST;

  SizeSpec.matchParent() : measureSpec = MeasureSpec.EXACTLY;

  double get value => _value ?? -1.0;
}

enum MeasureSpec { EXACTLY, AT_MOST }

class Box {
  SizeSpec width;
  SizeSpec height;
  BoxInsets padding;
  BoxInsets margin;
  ///TODO background可以单独拎出来，实现不同状态下的background
  Color background;
  Border border;
}

class BoxInsets {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const BoxInsets.all(double all)
      : left = all,
        top = all,
        right = all,
        bottom = all;

  const BoxInsets.only({
    this.left = 0.0,
    this.top = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
  });
}

///TODO Border暂定
class Border {

}

enum Visible {
  Gone, Visible, InVisible
}
