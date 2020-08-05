import 'package:flutter/rendering.dart';
import 'package:flutter_render_world/label/layout.dart';
import 'package:flutter_render_world/label/layout_compat.dart';
import 'package:flutter_render_world/render/renderview.dart';

class RenderFrameLayoutParentData extends RenderVueGroupParentData<FrameLayoutParams>{
  @override
  FrameLayoutParams createDefaultLayoutParams() => FrameLayoutParams(xGravity: Gravity.left, yGravity: Gravity.top);
}

class RenderFrameLayout extends RenderVueGroup<RenderFrameLayoutParentData>{
  FrameLayout frameLayout;

  RenderFrameLayout(this.frameLayout): super(frameLayout);

  @override
  Size onMeasure(double width, double height, BoxConstraints childBoxConstraints, bool parentUsesChildWidth, bool parentUsesChildHeight) {
    RenderVue child = firstChild;
    double maxChildWidth = 0.0;
    double maxChildHeight = 0.0;
    ///遍历所有子节点，所有子节点进行measure，且找出子节点中最大的宽度与高度
    while(child != null) {
      child.layout(childBoxConstraints, parentUsesSize: true);
      Size childSize = child.size;
      if (parentUsesChildWidth && childSize.width > maxChildWidth) {
        maxChildWidth = childSize.width;
      }
      if (parentUsesChildHeight && childSize.height > maxChildHeight) {
        maxChildHeight = childSize.height;
      }
      RenderFrameLayoutParentData data = child.parentData;
      child = data.nextSibling;
    }

    if (parentUsesChildWidth) {
      width = maxChildWidth + frameLayout.padding.horizontal;
      width = width.clamp(constraints.minWidth, constraints.maxWidth);
    }

    if (parentUsesChildHeight) {
      height = maxChildHeight + frameLayout.padding.vertical;
      height = height.clamp(constraints.minHeight, constraints.maxHeight);
    }

    child = firstChild;
    while(child != null) {
      Size childSize = child.size;
      RenderFrameLayoutParentData data = child.parentData;
      data.offset = Offset.zero;
      FrameLayoutParams lp = data.lp;

      if (lp.xGravity == Gravity.left) {
        double xOffset = frameLayout.padding.left + child.view.margin.left;
        data.offset += Offset(xOffset, 0);
      } else if (lp.xGravity == Gravity.center) {
        double xOffset = (width - frameLayout.padding.horizontal - childSize.width)/2 + child.view.margin.left - child.view.margin.right;
        data.offset += Offset(xOffset, 0);
      } else  if (lp.xGravity == Gravity.right) {
        double xOffset = width - frameLayout.padding.horizontal - child.size.width - child.view.margin.right;
        data.offset += Offset(xOffset, 0);
      }

      if (lp.yGravity == Gravity.top) {
        double yOffset = frameLayout.padding.top + child.view.margin.top;
        data.offset += Offset(0, yOffset);
      } else if (lp.yGravity == Gravity.center) {
        double yOffset = (height - frameLayout.padding.vertical - childSize.height)/2 + child.view.margin.top - child.view.margin.bottom;
        data.offset += Offset(0, yOffset);
      } else  if (lp.yGravity == Gravity.bottom) {
        double yOffset = height - frameLayout.padding.vertical - child.size.height - child.view.margin.bottom;
        data.offset += Offset(0, yOffset);
      }
      child = data.nextSibling;
    }

    return Size(width, height);
  }

  @override
  RenderFrameLayoutParentData createDefaultParentData() => RenderFrameLayoutParentData();

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return super.hitTestChildren(result, position: position);
  }
}