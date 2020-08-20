import 'package:flutter/cupertino.dart';
import 'package:flutter_render_world/div/ui-config/box.dart';

abstract class RenderView extends RenderBox{
  Box box;

  @override
  // TODO: implement sizedByParent
  bool get sizedByParent {
    SizeSpec width = box.width;
    SizeSpec height = box.height;
    return width.measureSpec == MeasureSpec.EXACTLY && height.measureSpec ==
        MeasureSpec.EXACTLY;
  }
  ///当前的RenderBox被标记为markNeedLayout时，会在window
  ///.onDrawFrame时调用此RenderBox的[performLayout]方法
  @override
  void performLayout() {
    super.performLayout();
  }
}

class RenderViewGroup {}

