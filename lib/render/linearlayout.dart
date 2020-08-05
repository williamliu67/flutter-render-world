import 'package:flutter/rendering.dart';
import 'package:flutter_render_world/label/layout.dart';
import 'package:flutter_render_world/label/layout_compat.dart';
import 'package:flutter_render_world/render/renderview.dart';

class RenderLinearLayoutParentData extends RenderVueGroupParentData<LinearLayoutParams>{
  @override
  LinearLayoutParams createDefaultLayoutParams() => LinearLayoutParams(xGravity: Gravity.left, yGravity: Gravity.top);
}

class RenderLinearLayout extends RenderVueGroup<RenderLinearLayoutParentData>{
  LinearLayout linearLayout;

  RenderLinearLayout(this.linearLayout):super(linearLayout);

  @override
  Size onMeasure(double width, double height, BoxConstraints childBoxConstraints, bool parentUsesChildWidth, bool parentUsesChildHeight) {
    print("RenderLinearLayout onMeasure");
    int direction = linearLayout.direction;
    if (direction == 0) {
      return performLayoutVertical(width, height, childBoxConstraints, parentUsesChildWidth, parentUsesChildHeight);
    } else {
      return performLayoutHorizontal(width, height, childBoxConstraints, parentUsesChildWidth, parentUsesChildHeight);
    }
  }

  Size performLayoutVertical(double width, double height,
      BoxConstraints childBoxConstraints,
      bool parentUsesChildWidth, bool parentUsesChildHeight) {
    RenderVue child = firstChild;
    double maxChildWidth = 0.0;
    double dy = 0.0;
    ///遍历子节点，并且通过不断计算剩余空间，改变子节点约束，从而不断计算出子节点size，同时也可以计算出高度最大的子节点
    while (child !=null) {
      child.layout(childBoxConstraints, parentUsesSize: true);
      Size childSize = child.size;
      if (parentUsesChildHeight && childSize.width > maxChildWidth) {
        maxChildWidth = childSize.width;
      }
      RenderLinearLayoutParentData data = child.parentData;
      data.offset = Offset.zero;
      ///子节点进行位置平移
      data.offset += Offset(0, dy);
      data.offset += Offset(0, child.view.margin.top);
      dy+= childSize.height + child.view.margin.vertical;
      childBoxConstraints = childBoxConstraints.deflate(EdgeInsets.fromLTRB(0, 0, 0, childSize.height + child.view.margin.vertical));
      child = data.nextSibling;
    }
    if (parentUsesChildWidth) {
      width = maxChildWidth + linearLayout.padding.horizontal;
      width = width.clamp(constraints.minWidth, constraints.maxWidth);
    }
    if (parentUsesChildHeight) {
      height = dy + linearLayout.margin.vertical + linearLayout.padding.vertical;
      height = height.clamp(constraints.minHeight, constraints.maxHeight);
    }
    ///2.根据字节的layoutGravity，计算出它的offset
    child = firstChild;
    while (child != null) {
      Size childSize = child.size;
      RenderLinearLayoutParentData data = child.parentData;
      LinearLayoutParams lp = data.lp;
      /// 计算x轴重心
      if (lp.xGravity == Gravity.left) {
        double xOffset = linearLayout.padding.left - child.view.margin.left;
        data.offset += Offset(xOffset, 0);
      } else if (lp.xGravity == Gravity.center) {
        double xOffset = (width - linearLayout.padding.horizontal - childSize.width)/2 + child.view.margin.left - child.view.margin.right;
        data.offset += Offset(xOffset, 0);
      } else  if (lp.xGravity == Gravity.right) {
        double xOffset = width - linearLayout.padding.horizontal - child.size.width - child.view.margin.right;
        data.offset += Offset(xOffset, 0);
      }
      child = data.nextSibling;
    }
    return Size(width, height);
  }

  Size performLayoutHorizontal(double width, double height,
      BoxConstraints childBoxConstraints,
      bool parentUsesChildWidth, bool parentUsesChildHeight) {
    RenderVue child = firstChild;
    double maxChildHeight = 0.0;
    double dx = 0.0;
    ///遍历子节点，并且通过不断计算剩余空间，改变子节点约束，从而不断计算出子节点size，同时也可以计算出高度最大的子节点
    while (child !=null) {
      child.layout(childBoxConstraints, parentUsesSize: true);
      Size childSize = child.size;
      if (parentUsesChildHeight && childSize.height > maxChildHeight) {
        maxChildHeight = childSize.height;
      }
      RenderLinearLayoutParentData data = child.parentData;
      data.offset = Offset.zero;
      ///子节点进行位置平移
      data.offset += Offset(dx, 0);
      data.offset += Offset(child.view.margin.left, 0);
      dx += childSize.width + child.view.margin.horizontal;
      childBoxConstraints = childBoxConstraints.deflate(EdgeInsets.fromLTRB(0, 0, childSize.width + child.view.margin.horizontal, 0));
      child = data.nextSibling;
    }
    if (parentUsesChildHeight) {
      height = maxChildHeight + linearLayout.margin.vertical + linearLayout.padding.vertical;
      height = height.clamp(constraints.minHeight, constraints.maxHeight);
    }
    if (parentUsesChildWidth) {
      width = dx + linearLayout.margin.horizontal + linearLayout.padding.horizontal;
      width = width.clamp(constraints.minWidth, constraints.maxWidth);
    }
    ///2.根据字节的layoutGravity，计算出它的offset
    child = firstChild;
    while (child != null) {
      Size childSize = child.size;
      RenderLinearLayoutParentData data = child.parentData;
      LinearLayoutParams lp = data.lp;
      /// 计算y轴重心
      if (lp.yGravity == Gravity.top) {

      } else if (lp.yGravity == Gravity.center) {
        double yOffset = (height - linearLayout.margin.vertical - linearLayout.padding.vertical - childSize.height)/2;
        data.offset += Offset(0, yOffset);
      } else  if (lp.yGravity == Gravity.bottom) {
        double yOffset = height - linearLayout.margin.vertical - linearLayout.padding.vertical - child.size.height;
        data.offset += Offset(0, yOffset);
      }
      child = data.nextSibling;
    }
    return Size(width, height);
  }

  @override
  RenderLinearLayoutParentData createDefaultParentData() => RenderLinearLayoutParentData();
}