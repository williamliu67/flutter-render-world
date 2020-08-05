import 'package:flutter/rendering.dart';
import 'package:flutter_render_world/label/layout.dart';

///主要存放辅助配置
class SizeSpec{
  double _value;
  MeasureSpec measureSpec;
  SizeSpec(this._value):measureSpec = MeasureSpec.EXACTLY;
  SizeSpec.wrapContent():measureSpec = MeasureSpec.AT_MOST;
  SizeSpec.matchParent():measureSpec = MeasureSpec.EXACTLY;

  double get value => _value??-1.0;
}

class LayoutGravity{
  Gravity xGravity;
  Gravity yGravity;

  LayoutGravity({Gravity x, Gravity y}): xGravity = x, yGravity = y;
}

enum MeasureSpec{
  EXACTLY, AT_MOST
}

enum Gravity{
  left, top, right, bottom, center,
}


