import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_render_world/label/layout.dart';
import 'package:flutter_render_world/label/layout_compat.dart';
import 'package:flutter_render_world/label/view.dart';

class RenderVue extends RenderBox{
  Paint _painter;
  View _view;

  RenderVue(this._view);

  View get view => _view;

  @override
  bool get sizedByParent => _view.widthSpec.measureSpec == MeasureSpec.EXACTLY
      && _view.heightSpec.measureSpec == MeasureSpec.EXACTLY;

  @override
  void performResize() {
    double width;
    double height;
    SizeSpec widthSpec = _view.widthSpec;
    SizeSpec heightSpec = _view.heightSpec;
    if (widthSpec.value == -1) {
      width = constraints.maxWidth;
    } else {
      width = widthSpec.value;
    }
    if (heightSpec.value == -1) {
      height = constraints.maxHeight;
    } else {
      height = heightSpec.value;
    }

    size = Size(width.clamp(constraints.minWidth, constraints.maxWidth), height.clamp(constraints.minHeight, constraints.maxHeight));
  }

  @override
  void performLayout() {
    _measure();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _clipBorderRadius(context, offset, () {
      _paintBkg(context, offset, painter);
      onDraw(context, offset);
    });
  }

  bool hitTestSelf(Offset position) {
    ///return false;
    return Size(size.width, size.height).contains(position);
  }

  Paint get painter => _painter??=Paint()..isAntiAlias = true;

  Size onMeasure(double width, double height,
      BoxConstraints childBoxConstraints,
      bool parentUsesChildWidth, bool parentUsesChildHeight) => Size(width, height);

  onDraw(PaintingContext context, Offset offset){}

  _measure(){
    SizeSpec widthSpec = _view.widthSpec;
    SizeSpec heightSpec = _view.heightSpec;

    double minChildWidth;
    double maxChildWidth;
    double minChildHeight;
    double maxChildHeight;
    double width;
    double height;

    bool parentUsesChildWidth = false;
    bool parentUsesChildHeight = false;

    if (widthSpec.measureSpec == MeasureSpec.EXACTLY) {
      minChildWidth = 0.0;
      ///match_parent
      if (widthSpec.value == -1) {
        width = constraints.maxWidth;
        maxChildWidth = width;
        maxChildWidth = maxChildWidth.clamp(0.0, width);
      } else {
        ///设置的具体的值
        width = widthSpec.value;
        maxChildWidth = widthSpec.value;
        maxChildWidth = maxChildWidth.clamp(0.0, widthSpec.value);
      }
    } else if (widthSpec.measureSpec == MeasureSpec.AT_MOST) {
      ///wrap_content
      width = 0.0;
      minChildWidth = 0.0;
      maxChildWidth = constraints.maxWidth;
      maxChildWidth = maxChildWidth.clamp(minChildWidth, constraints.maxWidth);
      parentUsesChildWidth = true;
    }

    if (heightSpec.measureSpec == MeasureSpec.EXACTLY) {
      minChildHeight = 0.0;
      if (heightSpec.value == -1) {
        ///match_parent
        height = constraints.maxHeight;
        maxChildHeight = height;
        maxChildHeight = maxChildHeight.clamp(0.0, height);
      } else {
        ///设置的具体的值
        height = heightSpec.value;
        maxChildHeight = heightSpec.value;
        maxChildHeight = maxChildHeight.clamp(0.0, heightSpec.value);
      }
    } else if (heightSpec.measureSpec == MeasureSpec.AT_MOST) {
      ///wrap_content
      height = 0.0;
      minChildHeight = 0.0;
      maxChildHeight = constraints.maxHeight;
      maxChildHeight = maxChildHeight.clamp(minChildHeight, constraints.maxHeight);
      parentUsesChildHeight = true;
    }
    width = width.clamp(constraints.minWidth, constraints.maxWidth);
    height = height.clamp(constraints.minHeight, constraints.maxHeight);
    BoxConstraints childBoxConstraints = BoxConstraints(minWidth: minChildWidth, maxWidth: maxChildWidth, minHeight: minChildHeight, maxHeight: maxChildHeight);
    childBoxConstraints = childBoxConstraints.deflate(view.padding);
    Size measureSize = onMeasure(width, height, childBoxConstraints, parentUsesChildWidth, parentUsesChildHeight);
    if (!sizedByParent) {
      size = measureSize;
    }
  }

  _paintBkg(PaintingContext context, Offset offset, Paint painter){
    if (_view.background != null) {
      Rect rect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
      painter.color = _view.background;
      context.canvas.drawRect(rect, painter);
    }
  }

  _clipBorderRadius(PaintingContext context, Offset offset, VoidCallback callback){
    if (_view.borderRadius != null) {
      BorderRadius borderRadius = _view.borderRadius;
      context.canvas.save();
      Rect contentRect = Rect.fromLTWH(
        offset.dx, offset.dy, size.width, size.height);
      RRect rRect = RRect.fromRectAndCorners(
        contentRect, topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight);
      context.canvas.clipRRect(rRect, doAntiAlias: true);
      callback();
      context.canvas.restore();
    } else {
      callback();
    }
  }

  bool onTouchEvent(Offset position) => false;
}

class RenderVueGroupParentData<T extends LayoutParams> extends ContainerBoxParentData<RenderVue>{
  T _lp;

  set lp(T layoutParams) => _lp = layoutParams;

  T get lp => _lp??=createDefaultLayoutParams();

  T createDefaultLayoutParams() => null;
}

abstract class RenderVueGroup<T extends RenderVueGroupParentData> extends RenderVue with ContainerRenderObjectMixin<RenderVue, T>,
    RenderBoxContainerDefaultsMixin<RenderVue, T>{
  ViewGroup _layout;

  RenderVueGroup(this._layout):super(_layout){
    removeAll();
    for (View view in _layout.children) {
      RenderBox child = view.renderVue;
      add(child);
    }
  }

  @override
  void setupParentData(RenderVue child) {
    if (child.parentData is! RenderVueGroupParentData) {
      T data = createDefaultParentData();
      data.lp = child.view.layoutParams;
      child.parentData = data;
    }
  }

  @override
  onDraw(PaintingContext context, Offset offset) {
    Offset padding = Offset(_layout.padding.left, _layout.padding.top);
    offset = offset + padding;
    RenderBox child = firstChild;
    while (child != null) {
      RenderVueGroupParentData data = child.parentData;
      context.paintChild(child, offset + data.offset);
      child = data.nextSibling;
    }
  }

  T createDefaultParentData();

  bool hitTestChildren(BoxHitTestResult result, { Offset position }) {
    /*Size contentSize = Size(size.width - view.margin.horizontal, size.height - view.margin.vertical);
    bool hitResult = contentSize.contains(position);
    if (!hitResult) {
      return false;
    }
    bool intercept = onInterceptTouchEvent(position);*/
    bool hit = false;
    RenderVue child = firstChild;
    if (position.dx <0 || position.dy < 0) {
      return false;
    }
    while(child != null) {
      RenderVueGroupParentData data = child.parentData;
      hit = child.hitTest(result, position: position - data.offset);
      if (hit) {
        break;
      }
      child = data.nextSibling;
    }
    return hit;
  }

  @override
  bool hitTestSelf(Offset position) {
    bool hit = super.hitTestSelf(position);
    return hit && onInterceptTouchEvent(position);
  }

  bool onInterceptTouchEvent(Offset position) => true;
}